from appwrite.client import Client
from appwrite.query import Query
from appwrite.services.databases import Databases
from appwrite.services.teams import Teams
import json
import os


DATABASE_ID = "tr_database"
DESIGNS_COLLECTION_ID = "products"
DESIGN_REVIEWS_COLLECTION_ID = "design_reviews"
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
        feedback = ""

        raw_body = context.req.body

        if isinstance(raw_body, str):
            try:
                body = json.loads(raw_body) if raw_body.strip() else {}
            except json.JSONDecodeError:
                body = {}
        else:
            body = raw_body if isinstance(raw_body, dict) else {}

        if body:
            design_id = str(body.get("designId", "")).strip()
            status = str(body.get("status", "")).strip().lower()
            feedback = str(body.get("feedback", "")).strip()

        if not design_id:
            return context.res.json(
                {
                    "success": False,
                    "error": "designId is required",
                },
                400,
            )

        if status not in ("approved", "rejected", "needs_revision"):
            return context.res.json(
                {
                    "success": False,
                    "error": "status must be approved, rejected or needs_revision",
                },
                400,
            )

        if status in ("rejected", "needs_revision") and not feedback:
            return context.res.json(
                {
                    "success": False,
                    "error": "feedback is required for rejected or needs_revision designs",
                },
                400,
            )

        document = databases.get_document(
            database_id=DATABASE_ID,
            collection_id=DESIGNS_COLLECTION_ID,
            document_id=design_id,
        )

        data = document.data if hasattr(document, "data") else document.get("data", {})
        designer_id = str(
            data.get("designer_id")
            or data.get("designerId")
            or data.get("ownerId")
            or ""
        ).strip()

        if not designer_id:
            return context.res.json(
                {
                    "success": False,
                    "error": "designer_id is missing on the design",
                    "designId": design_id,
                },
                422,
            )

        stored_status = "published" if status == "approved" else status

        databases.update_document(
            database_id=DATABASE_ID,
            collection_id=DESIGNS_COLLECTION_ID,
            document_id=design_id,
            data={
                "status": stored_status,
            },
        )

        review_data = {
            "design_id": design_id,
            "designer_id": designer_id,
            "status": status,
            "feedback": feedback,
            "reviewer_id": user_id,
        }

        try:
            databases.create_document(
                database_id=DATABASE_ID,
                collection_id=DESIGN_REVIEWS_COLLECTION_ID,
                document_id="unique()",
                data=review_data,
            )
        except Exception as review_error:
            context.log(f"DESIGN REVIEW LOG ERROR: {review_error}")

        context.log(
            f"DESIGN {design_id} UPDATED TO {stored_status} BY {user_id}"
        )

        return context.res.json(
            {
                "success": True,
                "service": "design-approval",
                "designId": design_id,
                "status": stored_status,
                "reviewStatus": status,
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
