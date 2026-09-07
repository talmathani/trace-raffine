from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.services.teams import Teams
from appwrite.query import Query
import json
import os

DATABASE_ID = "tr_database"
USERS_COLLECTION_ID = "users_profiles"
AUDIT_LOGS_COLLECTION_ID = "audit_logs"
ADMINS_TEAM_ID = "tr-admins"


def _client() -> Client:
    client = Client()
    client.set_endpoint(os.environ["APPWRITE_FUNCTION_API_ENDPOINT"])
    client.set_project(os.environ["APPWRITE_FUNCTION_PROJECT_ID"])
    client.set_key(os.environ["APPWRITE_API_KEY"])
    return client


def _user_id(context) -> str:
    headers = context.req.headers or {}

    for key in ("x-appwrite-user-id", "X-Appwrite-User-Id"):
        value = str(headers.get(key, "")).strip()

        if value:
            return value

    return ""


def _doc_data(document):
    if hasattr(document, "data") and isinstance(document.data, dict):
        return document.data
    if isinstance(document, dict):
        return document.get("data", document)
    return {}


def _is_admin(teams: Teams, user_id: str) -> bool:
    memberships = teams.list_memberships(
        team_id=ADMINS_TEAM_ID,
        queries=[
            Query.equal("userId", user_id),
        ],
    )

    items = (
        memberships.get("memberships", [])
        if isinstance(memberships, dict)
        else getattr(memberships, "memberships", [])
    )
    return len(items) > 0


def _user_summary(document):
    data = _doc_data(document)

    return {
        "userId": str(data.get("user_id", "")),
        "name": str(data.get("full_name", "")),
        "email": str(data.get("email", "")),
        "role": str(data.get("role", "")),
        "isSuspended": bool(data.get("is_suspended", False)),
        "lastSeen": data.get("last_seen"),
    }


def _list_users(databases: Databases):
    result = databases.list_documents(
        database_id=DATABASE_ID,
        collection_id=USERS_COLLECTION_ID,
        queries=[
            Query.limit(100),
        ],
    )

    docs = (
        result.get("documents", [])
        if isinstance(result, dict)
        else getattr(result, "documents", [])
    )
    return [
        _user_summary(document)
        for document in docs
    ]


def _list_designers(databases: Databases):
    result = databases.list_documents(
        database_id=DATABASE_ID,
        collection_id=USERS_COLLECTION_ID,
        queries=[
            Query.equal("role", "designer"),
            Query.limit(100),
        ],
    )

    docs = (
        result.get("documents", [])
        if isinstance(result, dict)
        else getattr(result, "documents", [])
    )
    return [
        _user_summary(document)
        for document in docs
    ]


def main(context):
    context.log("TR ADMIN USER CONTROL START")

    try:
        admin_id = _user_id(context)

        if not admin_id:
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

        if not _is_admin(teams, admin_id):
            return context.res.json(
                {
                    "success": False,
                    "error": "Administrator access required",
                },
                403,
            )

        raw_body = context.req.body

        if isinstance(raw_body, str):
            try:
                body = json.loads(raw_body) if raw_body.strip() else {}
            except json.JSONDecodeError:
                body = {}
        else:
            body = raw_body if isinstance(raw_body, dict) else {}

        action = str(body.get("action", "")).strip().lower()

        if action == "list_users":
            users = _list_users(databases)

            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "users": users,
                }
            )

        if action == "list_designers":
            designers = _list_designers(databases)

            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "designers": designers,
                }
            )

        target_user_id = str(body.get("userId", "")).strip()

        if action not in ("suspend", "reactivate", "status"):
            return context.res.json(
                {
                    "success": False,
                    "error": "action must be list_users, list_designers, suspend, reactivate or status",
                },
                400,
            )

        if not target_user_id:
            return context.res.json(
                {
                    "success": False,
                    "error": "userId is required",
                },
                400,
            )

        document = databases.get_document(
            database_id=DATABASE_ID,
            collection_id=USERS_COLLECTION_ID,
            document_id=target_user_id,
        )

        doc_data = _doc_data(document)

        role = str(
            doc_data.get("role", "")
        ).strip().lower()

        if role != "designer":
            return context.res.json(
                {
                    "success": False,
                    "error": "Only designer accounts can be controlled by this service",
                    "userId": target_user_id,
                    "role": role,
                },
                400,
            )

        current_suspended = bool(
            doc_data.get("is_suspended", False)
        )

        if action == "status":
            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "userId": target_user_id,
                    "role": role,
                    "isSuspended": current_suspended,
                    "lastSeen": doc_data.get("last_seen"),
                }
            )

        new_suspended = action == "suspend"

        if new_suspended == current_suspended:
            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "userId": target_user_id,
                    "role": role,
                    "isSuspended": current_suspended,
                    "changed": False,
                }
            )

        databases.update_document(
            database_id=DATABASE_ID,
            collection_id=USERS_COLLECTION_ID,
            document_id=target_user_id,
            data={
                "is_suspended": new_suspended,
            },
        )

        audit_action = (
            "suspend_designer"
            if new_suspended
            else "reactivate_designer"
        )

        try:
            databases.create_document(
                database_id=DATABASE_ID,
                collection_id=AUDIT_LOGS_COLLECTION_ID,
                document_id="unique()",
                data={
                    "user_id": admin_id,
                    "action": audit_action,
                    "entity": "user",
                    "entity_id": target_user_id,
                    "metadata_json": json.dumps(
                        {
                            "role": role,
                            "is_suspended": new_suspended,
                        }
                    ),
                },
            )
        except Exception as audit_error:
            context.log(f"AUDIT LOG ERROR: {audit_error}")

        return context.res.json(
            {
                "success": True,
                "service": "admin-user-control",
                "userId": target_user_id,
                "role": role,
                "isSuspended": new_suspended,
                "changed": True,
            }
        )

    except Exception as error:
        context.log("TR ADMIN USER CONTROL ERROR")
        context.log(str(error))

        return context.res.json(
            {
                "success": False,
                "service": "admin-user-control",
                "status": "error",
                "error": str(error),
            },
            500,
        )
