from appwrite.client import Client
from appwrite.services.storage import Storage
import os


BUCKET_ID = "design-files"


def main(context):
    context.log("TR EMBROIDERY ANALYZER START")

    try:
        file_id = ""

        if context.req.query:
            file_id = str(
                context.req.query.get("fileId", "")
            ).strip()

        if not file_id:
            return context.res.json(
                {
                    "success": False,
                    "error": "fileId is required",
                },
                400,
            )

        context.log("FILE ID RECEIVED")

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

        storage = Storage(client)

        file = storage.get_file(
            bucket_id=BUCKET_ID,
            file_id=file_id,
        )

        file_data = file.model_dump()

        file_name = str(file_data.get("name", ""))
        extension = ""

        if "." in file_name:
            extension = file_name.rsplit(".", 1)[-1].lower()

        result = {
            "success": True,
            "service": "embroidery-analyzer",
            "status": "file-read",
            "file": {
                "id": str(file_data.get("id", "")),
                "name": file_name,
                "mimeType": str(file_data.get("mime_type", "")),
                "sizeOriginal": int(file_data.get("size_original", 0)),
                "extension": extension,
            },
        }

        context.log("FILE READ SUCCESSFULLY")

        return context.res.json(result)

    except Exception as error:
        context.log("ANALYZER ERROR")

        return context.res.json(
            {
                "success": False,
                "service": "embroidery-analyzer",
                "status": "error",
                "error": str(error),
            },
            500,
        )



