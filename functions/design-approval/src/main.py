from appwrite.client import Client
from appwrite.query import Query
from appwrite.services.databases import Databases
from appwrite.services.teams import Teams
import os


DATABASE_ID = "tr_database"
DESIGNS_COLLECTION_ID = "designer_designs"
ADMINS_TEAM_ID = "tr-admins"


def _client() -> Client:
    client = Client()
    client.set_endpoint(os.environ["APPWRITE_FUNCTION_API_ENDPOINT"])
    client.set_project(os.environ["APPWRITE_FUNCTION_PROJECT_ID"])
    client.set_key(os.environ["APPWRITE_API_KEY"])
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


def _is_admin(teams: Teams, user_id: str) -> bool:
    memberships = teams.list_memberships(
        team_id=ADMINS_TEAM_ID,
        queries=[
            Query.equal("userId", user_id),
        ],
        total=False,
    )

    return len(memberships.memberships) > 0


def main(context):
    context.log("TR DESIGN APPROVAL START")

    try:
        user_id = _user_id(context)

        if not user_id:
            return context.res.json(
                {
                    "success": False,
                    "error": "Authenticated user is required",
                },
                401,
            )

        client = _client()
        databases = Databases(client)
        teams = Teams(client)

        if not _is_admin(teams, user_id):
            context.log("DESIGN APPROVAL DENIED")

            return context.res.json(
                {
                    "success": False,
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

        if not design_id:
            return context.res.json(
                {
                    "success": False,
                    "error": "designId is required",
                },
                400,
            )

        if status not in ("approved", "rejected"):
            return context.res.json(
                {
                    "success": False,
                    "error": "status must be approved or rejected",
                },
                400,
            )

        databases.get_document(
            database_id=DATABASE_ID,
            collection_id=DESIGNS_COLLECTION_ID,
            document_id=design_id,
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
            }
        )

    except Exception as error:
        context.log("DESIGN APPROVAL ERROR")
        context.log(str(error))

        return context.res.json(
            {
                "success": False,
                "service": "design-approval",
                "status": "error",
                "error": str(error),
            },
            500,
        )
