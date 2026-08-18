import pyembroidery
from io import BytesIO

from appwrite.client import Client
from appwrite.query import Query
from appwrite.services.databases import Databases
from appwrite.services.storage import Storage
from appwrite.services.teams import Teams
import os


DATABASE_ID = "tr_database"
DESIGNS_COLLECTION_ID = "designer_designs"
ADMINS_TEAM_ID = "tr-admins"
BUCKET_ID = "design-files"


def _client() -> Client:
    client = Client()
    client.set_endpoint(
        os.environ["APPWRITE_FUNCTION_API_ENDPOINT"]
    )
    client.set_project(
        os.environ["APPWRITE_FUNCTION_PROJECT_ID"]
    )
    client.set_key(
        os.environ["APPWRITE_API_KEY"]
    )
    return client


def _user_id(context) -> str:
    headers = context.req.headers or {}

    for key in (
        "x-appwrite-user-id",
        "X-Appwrite-User-Id",
    ):
        value = str(headers.get(key, "")).strip()
        if value:
            return value

    return ""


def _is_admin(
    teams: Teams,
    user_id: str,
) -> bool:
    memberships = teams.list_memberships(
        team_id=ADMINS_TEAM_ID,
        queries=[
            Query.equal("userId", user_id),
        ],
        total=False,
    )

    return len(memberships.memberships) > 0


def _get_file_id(context) -> str:
    file_id = ""

    if context.req.query:
        file_id = str(
            context.req.query.get("fileId", "")
        ).strip()

    if file_id:
        return file_id

    if context.req.body:
        body = context.req.body

        if isinstance(body, dict):
            return str(
                body.get("fileId", "")
            ).strip()

    return ""


def _get_action(context) -> str:
    action = ""

    if context.req.query:
        action = str(
            context.req.query.get("action", "")
        ).strip().lower()

    if action:
        return action

    if context.req.body:
        body = context.req.body

        if isinstance(body, dict):
            return str(
                body.get("action", "")
            ).strip().lower()

    return ""


def _handle_design_approval(context):
    user_id = _user_id(context)

    if not user_id:
        return context.res.json(
            {
                "success": False,
                "service": "design-approval",
                "error": "Authenticated user is required",
            },
            401,
        )

    client = _client()

    teams = Teams(client)
    databases = Databases(client)

    if not _is_admin(teams, user_id):
        context.log(
            "DESIGN APPROVAL DENIED"
        )

        return context.res.json(
            {
                "success": False,
                "service": "design-approval",
                "error": "Administrator access required",
            },
            403,
        )

    design_id = ""
    status = ""

    if context.req.body:
        body = context.req.body

        if isinstance(body, dict):
            design_id = str(
                body.get("designId", "")
            ).strip()

            status = str(
                body.get("status", "")
            ).strip().lower()

    if not design_id and context.req.query:
        design_id = str(
            context.req.query.get(
                "designId",
                "",
            )
        ).strip()

    if not status and context.req.query:
        status = str(
            context.req.query.get(
                "status",
                "",
            )
        ).strip().lower()

    if not design_id:
        return context.res.json(
            {
                "success": False,
                "service": "design-approval",
                "error": "designId is required",
            },
            400,
        )

    if status not in (
        "approved",
        "rejected",
    ):
        return context.res.json(
            {
                "success": False,
                "service": "design-approval",
                "error": (
                    "status must be approved or rejected"
                ),
            },
            400,
        )

    document = databases.get_document(
        database_id=DATABASE_ID,
        collection_id=DESIGNS_COLLECTION_ID,
        document_id=design_id,
    )

    current_data = document.model_dump()

    current_status = str(
        current_data.get("status", "")
    ).strip().lower()

    if current_status == status:
        return context.res.json(
            {
                "success": True,
                "service": "design-approval",
                "designId": design_id,
                "status": status,
                "changed": False,
            }
        )

    databases.update_document(
        database_id=DATABASE_ID,
        collection_id=DESIGNS_COLLECTION_ID,
        document_id=design_id,
        data={
            "status": status,
        },
    )

    context.log(
        f"DESIGN {design_id} UPDATED TO {status}"
    )

    return context.res.json(
        {
            "success": True,
            "service": "design-approval",
            "designId": design_id,
            "status": status,
            "changed": True,
        }
    )



def _read_int_ascii(data, start, length):
    raw = data[start:start + length]
    try:
        return int(raw.decode("ascii").strip() or "0")
    except (ValueError, UnicodeDecodeError):
        return 0


def _parse_dst_bytes(data):
    if not isinstance(data, (bytes, bytearray)):
        raise ValueError("Storage did not return binary bytes.")

    data = bytes(data)

    if len(data) < 512:
        raise ValueError(
            f"DST binary is too small: {len(data)} bytes."
        )

    header = data[:512]

    if not header.startswith(b"LA:"):
        raise ValueError(
            "Binary content does not contain a valid DST header."
        )

    label = header[3:20].decode(
        "ascii",
        errors="ignore",
    ).strip()

    stitch_count = _read_int_ascii(
        header,
        48,
        7,
    )

    color_changes = _read_int_ascii(
        header,
        48 + 0,
        7,
    )

    records = data[512:]

    record_count = len(records) // 3

    if record_count <= 0:
        raise ValueError(
            "DST contains no stitch records."
        )

    stitch_records = 0
    jump_records = 0
    trim_records = 0
    stop_records = 0

    x = 0
    y = 0

    min_x = None
    max_x = None
    min_y = None
    max_y = None

    for index in range(record_count):
        offset = index * 3
        record = records[offset:offset + 3]

        if len(record) != 3:
            break

        b0 = record[0]
        b1 = record[1]
        b2 = record[2]

        if b2 & 0xF3 == 0xF3:
            break

        dx = 0
        dy = 0

        if b0 & 0x01:
            dx += 1
        if b0 & 0x02:
            dx -= 1
        if b0 & 0x04:
            dx += 9
        if b0 & 0x08:
            dx -= 9
        if b0 & 0x10:
            dx += 3
        if b0 & 0x20:
            dx -= 3
        if b0 & 0x40:
            dx += 27
        if b0 & 0x80:
            dx -= 27

        if b1 & 0x01:
            dy += 1
        if b1 & 0x02:
            dy -= 1
        if b1 & 0x04:
            dy += 9
        if b1 & 0x08:
            dy -= 9
        if b1 & 0x10:
            dy += 3
        if b1 & 0x20:
            dy -= 3
        if b1 & 0x40:
            dy += 27
        if b1 & 0x80:
            dy -= 27

        command = b2

        is_end = (
            command & 0xF3
        ) == 0xF3

        if is_end:
            break

        is_jump = (
            command & 0x83
        ) == 0x83

        is_stop = (
            command & 0xC3
        ) == 0xC3

        if is_stop:
            stop_records += 1

        if is_jump:
            jump_records += 1
        else:
            stitch_records += 1

        x += dx
        y += dy

        if min_x is None or x < min_x:
            min_x = x

        if max_x is None or x > max_x:
            max_x = x

        if min_y is None or y < min_y:
            min_y = y

        if max_y is None or y > max_y:
            max_y = y

    if min_x is None:
        min_x = 0
        max_x = 0
        min_y = 0
        max_y = 0

    return {
        "format": "DST",
        "formatSource": "binary",
        "headerLabel": label,
        "headerStitchCount": stitch_count,
        "headerColorChanges": color_changes,
        "binarySize": len(data),
        "recordBytes": len(records),
        "recordCount": record_count,
        "stitchRecords": stitch_records,
        "jumpRecords": jump_records,
        "stopRecords": stop_records,
        "bounds": {
            "minX": min_x,
            "maxX": max_x,
            "minY": min_y,
            "maxY": max_y,
            "width": max_x - min_x,
            "height": max_y - min_y,
        },
    }

def _command_name(command):
    try:
        masked = command & pyembroidery.COMMAND_MASK

        if masked == pyembroidery.STITCH:
            return "STITCH"

        if masked == pyembroidery.JUMP:
            return "JUMP"

        if masked == pyembroidery.TRIM:
            return "TRIM"

        if masked == pyembroidery.STOP:
            return "STOP"

        if masked == pyembroidery.END:
            return "END"

        if masked == pyembroidery.COLOR_CHANGE:
            return "COLOR_CHANGE"

        if masked == pyembroidery.NEEDLE_SET:
            return "NEEDLE_SET"

        if masked == pyembroidery.SEQUIN_MODE:
            return "SEQUIN_MODE"

        if masked == pyembroidery.SEQUIN_EJECT:
            return "SEQUIN_EJECT"

        return "OTHER"

    except Exception:
        return "OTHER"


def _analyze_original_binary(file_name, file_bytes):

    if not isinstance(file_bytes, (bytes, bytearray)):
        raise ValueError(
            "Original storage content is not binary bytes."
        )

    original_bytes = bytes(file_bytes)

    if len(original_bytes) == 0:
        raise ValueError(
            "Original embroidery file is empty."
        )

    extension = ""

    if "." in file_name:
        extension = file_name.rsplit(
            ".",
            1,
        )[-1].lower()

    if not extension:
        raise ValueError(
            "Cannot determine embroidery format."
        )

    supported_formats = {
        "dst",
        "pes",
        "jef",
        "vp3",
        "exp",
        "pec",
        "xxx",
        "hus",
        "sew",
        "u01",
        "tap",
        "tbf",
        "dsb",
        "dsz",
        "emd",
        "phb",
        "phc",
        "stc",
        "stx",
        "mit",
        "ksm",
        "new",
        "inb",
        "pcs",
        "shv",
        "zxy",
        "bro",
        "fxy",
        "gt",
        "pcd",
        "pcm",
        "pcq",
        "dat",
    }

    if extension not in supported_formats:
        return {
            "status": "unsupported-format",
            "format": extension.upper(),
            "source": "original-binary",
            "binaryBytesRead": len(original_bytes),
            "facts": {},
        }

    stream = BytesIO(original_bytes)

    if extension == "dst":
        pattern = pyembroidery.read_dst(
            stream
        )
    else:
        pattern = pyembroidery.read(
            stream
        )

    if pattern is None:
        raise ValueError(
            "Embroidery parser returned no pattern."
        )

    stitches = getattr(
        pattern,
        "stitches",
        [],
    )

    threads = getattr(
        pattern,
        "threadlist",
        [],
    )

    stitch_count = 0
    jump_count = 0
    trim_count = 0
    stop_count = 0
    color_change_count = 0
    needle_change_count = 0
    sequin_mode_count = 0
    sequin_eject_count = 0
    end_count = 0
    other_command_count = 0

    min_x = None
    max_x = None
    min_y = None
    max_y = None

    for stitch in stitches:

        if len(stitch) < 3:
            continue

        x = float(stitch[0])
        y = float(stitch[1])
        command = int(stitch[2])

        if min_x is None or x < min_x:
            min_x = x

        if max_x is None or x > max_x:
            max_x = x

        if min_y is None or y < min_y:
            min_y = y

        if max_y is None or y > max_y:
            max_y = y

        command_type = _command_name(
            command
        )

        if command_type == "STITCH":
            stitch_count += 1

        elif command_type == "JUMP":
            jump_count += 1

        elif command_type == "TRIM":
            trim_count += 1

        elif command_type == "STOP":
            stop_count += 1

        elif command_type == "COLOR_CHANGE":
            color_change_count += 1

        elif command_type == "NEEDLE_SET":
            needle_change_count += 1

        elif command_type == "SEQUIN_MODE":
            sequin_mode_count += 1

        elif command_type == "SEQUIN_EJECT":
            sequin_eject_count += 1

        elif command_type == "END":
            end_count += 1

        else:
            other_command_count += 1

    width = 0
    height = 0

    if min_x is not None and max_x is not None:
        width = max_x - min_x

    if min_y is not None and max_y is not None:
        height = max_y - min_y

    thread_count = len(threads)

    encoded_color_events = (
        color_change_count
        + needle_change_count
    )

    estimated_color_regions = 0

    if stitch_count > 0:
        estimated_color_regions = (
            encoded_color_events + 1
        )

    extras = getattr(
        pattern,
        "extras",
        {},
    )

    if not isinstance(extras, dict):
        extras = {}

    return {
        "status": "analyzed",
        "format": extension.upper(),
        "source": "original-binary",
        "binaryBytesRead": len(original_bytes),

        "facts": {
            "stitchCount": stitch_count,
            "jumpCount": jump_count,
            "trimCount": trim_count,
            "stopCount": stop_count,

            "colorChanges": color_change_count,
            "needleChanges": needle_change_count,
            "encodedColorEvents": encoded_color_events,
            "estimatedColorRegions": estimated_color_regions,

            "threadRecords": thread_count,

            "sequinModeCount": sequin_mode_count,
            "sequinEjectCount": sequin_eject_count,

            "endMarkers": end_count,
            "otherCommands": other_command_count,

            "bounds": {
                "minX": min_x if min_x is not None else 0,
                "maxX": max_x if max_x is not None else 0,
                "minY": min_y if min_y is not None else 0,
                "maxY": max_y if max_y is not None else 0,
                "width": width,
                "height": height,
            },

            "beads": {
                "status": "not-explicitly-encoded",
                "count": None,
            },

            "sequins": {
                "status": (
                    "detected"
                    if sequin_eject_count > 0
                    else "not-detected"
                ),
                "count": sequin_eject_count,
            },

            "metadata": extras,
        },
    }

def _safe_int(value):
    try:
        if value is None:
            return None
        return int(value)
    except Exception:
        return None


def _safe_float(value):
    try:
        if value is None:
            return None
        return float(value)
    except Exception:
        return None


def _metadata_value(metadata, *keys):
    if not isinstance(metadata, dict):
        return None

    for key in keys:
        if key in metadata:
            value = metadata[key]

            if value is not None:
                return value

    return None


def _build_design_details(
    file_name,
    file_data,
    analysis,
):
    if not isinstance(file_data, dict):
        file_data = {}

    if not isinstance(analysis, dict):
        analysis = {}

    metadata = file_data.get(
        "metadata",
        {},
    )

    if not isinstance(metadata, dict):
        metadata = {}

    analysis_bounds = analysis.get(
        "bounds",
        {},
    )

    if not isinstance(analysis_bounds, dict):
        analysis_bounds = {}

    format_name = analysis.get(
        "format",
    )

    if not format_name:
        format_name = ""

    extension = ""

    if "." in file_name:
        extension = file_name.rsplit(
            ".",
            1,
        )[-1].lower()

    if not extension:
        extension = str(
            format_name
        ).lower()

    analysis_binary_size = _safe_int(
        analysis.get(
            "binarySize"
        )
    )

    original_size = _safe_int(
        file_data.get(
            "sizeOriginal"
        )
    )

    actual_size = _safe_int(
        file_data.get(
            "sizeActual"
        )
    )

    if original_size is None:
        original_size = analysis_binary_size

    if actual_size is None:
        actual_size = analysis_binary_size

    stitch_records = _safe_int(
        analysis.get(
            "stitchRecords"
        )
    )

    record_count = _safe_int(
        analysis.get(
            "recordCount"
        )
    )

    if stitch_records is None:
        stitch_records = record_count

    stitch_count = _safe_int(
        file_data.get(
            "stitchCount"
        )
    )

    if stitch_count is None:
        stitch_count = _safe_int(
            metadata.get(
                "stitchCount"
            )
        )

    if stitch_count is None:
        stitch_count = stitch_records

    jump_count = _safe_int(
        file_data.get(
            "jumpCount"
        )
    )

    if jump_count is None:
        jump_count = _safe_int(
            analysis.get(
                "jumpRecords"
            )
        )

    stop_count = _safe_int(
        file_data.get(
            "stopCount"
        )
    )

    if stop_count is None:
        stop_count = _safe_int(
            analysis.get(
                "stopRecords"
            )
        )

    trim_count = _safe_int(
        file_data.get(
            "trimCount"
        )
    )

    color_changes = _safe_int(
        file_data.get(
            "colorChanges"
        )
    )

    if color_changes is None:
        color_changes = _safe_int(
            analysis.get(
                "headerColorChanges"
            )
        )

    needle_changes = _safe_int(
        file_data.get(
            "needleChanges"
        )
    )

    thread_records = _safe_int(
        file_data.get(
            "threadRecords"
        )
    )

    if thread_records is None:
        thread_records = _safe_int(
            _metadata_value(
                metadata,
                "threadCount",
                "thread_count",
                "threads",
                "threadRecords",
            )
        )

    width = _safe_float(
        analysis_bounds.get(
            "width"
        )
    )

    height = _safe_float(
        analysis_bounds.get(
            "height"
        )
    )

    min_x = _safe_float(
        analysis_bounds.get(
            "minX"
        )
    )

    max_x = _safe_float(
        analysis_bounds.get(
            "maxX"
        )
    )

    min_y = _safe_float(
        analysis_bounds.get(
            "minY"
        )
    )

    max_y = _safe_float(
        analysis_bounds.get(
            "maxY"
        )
    )

    bead_count = _safe_int(
        file_data.get(
            "beadCount"
        )
    )

    sequin_count = _safe_int(
        file_data.get(
            "sequinCount"
        )
    )

    design_name = _metadata_value(
        metadata,
        "name",
        "designName",
        "design_name",
        "title",
        "label",
    )

    author = _metadata_value(
        metadata,
        "author",
        "designer",
        "creator",
        "createdBy",
    )

    description = _metadata_value(
        metadata,
        "description",
        "comment",
        "comments",
        "notes",
    )

    hoop_name = _metadata_value(
        metadata,
        "hoop",
        "hoopName",
        "hoop_name",
    )

    machine_name = _metadata_value(
        metadata,
        "machine",
        "machineName",
        "machine_name",
    )

    needle_count = _safe_int(
        _metadata_value(
            metadata,
            "needleCount",
            "needle_count",
            "needles",
        )
    )

    if needle_count is None:
        if needle_changes is not None:
            needle_count = needle_changes + 1

    explicit_color_count = _safe_int(
        _metadata_value(
            metadata,
            "colorCount",
            "color_count",
            "colors",
            "threadColorCount",
        )
    )

    if explicit_color_count is not None:
        color_count = explicit_color_count
        color_count_source = "embedded-metadata"
    else:
        color_count = None
        color_count_source = "not-available"

    return {
        "schemaVersion": 2,

        "source": {
            "mode": "read-only-original-binary",
            "fileName": file_name,
            "extension": extension.upper(),
            "format": format_name,
            "mimeType": file_data.get(
                "mimeType"
            ),
            "originalSizeBytes": original_size,
            "actualSizeBytes": actual_size,
        },

        "stitches": {
            "count": stitch_count,
            "recordCount": stitch_records,
        },

        "movement": {
            "jumps": jump_count,
            "trims": trim_count,
            "stops": stop_count,
        },

        "colors": {
            "count": color_count,
            "source": color_count_source,
            "changes": color_changes,
            "needleChanges": needle_changes,
        },

        "threads": {
            "count": thread_records,
        },

        "needles": {
            "count": needle_count,
        },

        "sequins": {
            "count": sequin_count,
            "status": (
                "not-available"
                if sequin_count is None
                else "reported"
            ),
        },

        "beads": {
            "count": bead_count,
            "status": (
                "not-available"
                if bead_count is None
                else "reported"
            ),
        },

        "dimensions": {
            "width": width,
            "height": height,
            "minX": min_x,
            "maxX": max_x,
            "minY": min_y,
            "maxY": max_y,
        },

        "embeddedMetadata": metadata,

        "fileVisibility": {
            "customerCanDownloadOriginal": False,
            "customerCanViewOriginal": False,
            "adminCanInspectOriginal": True,
        },

        "analysis": {
            "status": analysis.get(
                "status",
                "analyzed",
            ),
            "formatSource": analysis.get(
                "formatSource",
                "binary",
            ),
            "binarySize": analysis_binary_size,
            "recordBytes": _safe_int(
                analysis.get(
                    "recordBytes"
                )
            ),
            "recordCount": record_count,
            "stitchRecords": stitch_records,
            "jumpRecords": _safe_int(
                analysis.get(
                    "jumpRecords"
                )
            ),
            "stopRecords": _safe_int(
                analysis.get(
                    "stopRecords"
                )
            ),
            "headerStitchCount": _safe_int(
                analysis.get(
                    "headerStitchCount"
                )
            ),
            "headerColorChanges": _safe_int(
                analysis.get(
                    "headerColorChanges"
                )
            ),
        },

        "design": {
            "name": design_name,
            "author": author,
            "description": description,
            "hoop": hoop_name,
            "machine": machine_name,
        },
    }

def _handle_file_read(context):
    file_id = _get_file_id(context)

    if not file_id:
        return context.res.json(
            {
                "success": False,
                "service": "embroidery-analyzer",
                "error": "fileId is required",
            },
            400,
        )

    context.log(
        "FILE ID RECEIVED"
    )

    client = _client()
    storage = Storage(client)

    file = storage.get_file(
        bucket_id=BUCKET_ID,
        file_id=file_id,
    )

    file_data = file.model_dump()

    context.log(
        "READING ORIGINAL STORAGE BINARY"
    )

    file_bytes = storage.get_file_download(
        bucket_id=BUCKET_ID,
        file_id=file_id,
    )

    if not isinstance(file_bytes, (bytes, bytearray)):
        raise ValueError(
            "Storage binary response is not bytes."
        )

    binary_size = len(file_bytes)

    context.log(
        "ORIGINAL BINARY BYTES: "
        + str(binary_size)
    )


    file_name = str(
        file_data.get(
            "name",
            "",
        )
    )

    extension = ""

    if "." in file_name:
        extension = file_name.rsplit(
            ".",
            1,
        )[-1].lower()

    analysis = _analyze_original_binary(
        file_name,
        file_bytes,
    )

    result = {
        "success": True,
        "service": "embroidery-analyzer",
        "status": "file-read",
        "file": {
            "id": str(
                file_data.get(
                    "id",
                    "",
                )
            ),
            "name": file_name,
            "mimeType": str(
                file_data.get(
                    "mimetype",
                    "",
                )
            ),
            "sizeOriginal": int(
                float(
                    file_data.get(
                        "sizeoriginal",
                        0,
                    )
                )
            ),
            "sizeActual": int(
                float(
                    file_data.get(
                        "sizeactual",
                        0,
                    )
                )
            ),
            "extension": extension,
        },
    }

    analysis = None

    if file_name.lower().endswith(".dst"):
        analysis = _parse_dst_bytes(
            file_bytes
        )

    if analysis is not None:
        result["analysis"] = analysis
    design_details = _build_design_details(
        file_name,
        file_data,
        analysis,
    )

    result["designDetails"] = design_details

    result["binary"] = {
        "readFromStorage": True,
        "byteLength": binary_size,
    }

    context.log(
        "FILE BINARY ANALYSIS SUCCESSFULLY"
    )

    return context.res.json(result)


def main(context):
    context.log(
        "TR EMBROIDERY ANALYZER START"
    )

    try:
        action = _get_action(context)

        if action == "design-approval":
            return _handle_design_approval(
                context
            )

        return _handle_file_read(
            context
        )

    except Exception as error:
        context.log(
            "ANALYZER ERROR"
        )
        context.log(
            str(error)
        )

        return context.res.json(
            {
                "success": False,
                "service": "embroidery-analyzer",
                "status": "error",
                "error": str(error),
            },
            500,
        )









