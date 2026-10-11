from pathlib import Path
import sys
import traceback
import pyembroidery

root = Path(sys.argv[1])

files = [
    ("EMB", root / "TR03.EMB"),
    ("DST", root / "376.DST"),
    ("DHP", root / "TR03.DHP"),
    ("DHE", root / "Design17-1.dhe"),
]

print("=" * 80)
print("REAL PYEMBROIDERY READER PROBE")
print("=" * 80)
print("PACKAGE:", pyembroidery.__file__)
print("")

reader_map = {
    "DST": "read_dst",
    "EMB": None,
    "DHP": None,
    "DHE": None,
}

for fmt, path in files:
    print("-" * 80)
    print("FORMAT:", fmt)
    print("FILE  :", path)
    print("SIZE  :", path.stat().st_size if path.exists() else "MISSING")

    if not path.exists():
        print("RESULT: FILE MISSING")
        continue

    reader_name = reader_map.get(fmt)

    if reader_name is None:
        print("READER: NO PYEMBROIDERY READER")
        continue

    reader = getattr(pyembroidery, reader_name, None)

    if reader is None:
        print("READER SYMBOL MISSING:", reader_name)
        continue

    try:
        pattern = reader(str(path))

        print("RESULT:", "READ SUCCESS")
        print("STITCHES:", len(pattern.stitches))
        print("THREADS:", len(pattern.threadlist))

        try:
            print("EXTRAS:", pattern.extras)
        except Exception:
            print("EXTRAS: unavailable")

    except Exception as exc:
        print("RESULT: READ FAILED")
        print("ERROR:", repr(exc))
        traceback.print_exc()

print("")
print("=" * 80)
print("END REAL READER PROBE")
print("=" * 80)