from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.services.teams import Teams
from appwrite.query import Query
import json
import os

DATABASE_ID = "tr_database"
ORDERS_COLLECTION_ID = "orders"
AUDIT_LOGS_COLLECTION_ID = "audit_logs"
ADMINS_TEAM_ID = "tr-admins"
ALLOWED_STATUSES = {"pending", "paid", "processing", "completed", "cancelled"}


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


def _is_admin(teams: Teams, user_id: str) -> bool:
    memberships = teams.list_memberships(
        team_id=ADMINS_TEAM_ID,
        queries=[Query.equal("userId", user_id)],
    )
    items = memberships.get("memberships", []) if isinstance(memberships, dict) else getattr(memberships, "memberships", [])
    return len(items) > 0
def main(context):
    context.log("TR ADMIN ORDER CONTROL START")

    try:
        admin_id = _user_id(context)
        if not admin_id:
            return context.res.json(
                {"success": False, "error": "Authenticated user is required"},
                401,
            )

        client = _client()
        databases = Databases(client)
        teams = Teams(client)

        if not _is_admin(teams, admin_id):
            return context.res.json(
                {"success": False, "error": "Administrator access required"},
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
        order_id = str(body.get("orderId", "")).strip()
        status = str(body.get("status", "")).strip().lower()

        if action != "update_status":
            return context.res.json(
                {"success": False, "error": "action must be update_status"},
                400,
            )

        if not order_id:
            return context.res.json(
                {"success": False, "error": "orderId is required"},
                400,
            )

        if status not in ALLOWED_STATUSES:
            return context.res.json(
                {
                    "success": False,
                    "error": "Unsupported order status",
                    "allowedStatuses": sorted(ALLOWED_STATUSES),
                },
                400,
            )

        order = databases.get_document(
            database_id=DATABASE_ID,
            collection_id=ORDERS_COLLECTION_ID,
            document_id=order_id,
        )
        current_status = str(order.get("status", "")).strip().lower()
        if current_status == status:
            return context.res.json(
                {
                    "success": True,
                    "service": "admin-order-control",
                    "orderId": order_id,
                    "status": status,
                    "changed": False,
                }
            )

        databases.update_document(
            database_id=DATABASE_ID,
            collection_id=ORDERS_COLLECTION_ID,
            document_id=order_id,
            data={"status": status},
        )

        try:
            databases.create_document(
                database_id=DATABASE_ID,
                collection_id=AUDIT_LOGS_COLLECTION_ID,
                document_id="unique()",
                data={
                    "user_id": admin_id,
                    "action": "update_order_status",
                    "entity": "order",
                    "entity_id": order_id,
                    "metadata_json": json.dumps(
                        {
                            "from": current_status,
                            "to": status,
                        }
                    ),
                },
            )
        except Exception as audit_error:
            context.log(f"AUDIT LOG ERROR: {audit_error}")

        return context.res.json(
            {
                "success": True,
                "service": "admin-order-control",
                "orderId": order_id,
                "status": status,
                "changed": True,
            }
        )

    except Exception as error:
        context.log("TR ADMIN ORDER CONTROL ERROR")
        context.log(str(error))
        return context.res.json(
            {
                "success": False,
                "service": "admin-order-control",
                "status": "error",
                "error": str(error),
            },
            500,
        )
