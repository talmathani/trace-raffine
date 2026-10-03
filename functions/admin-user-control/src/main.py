from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.services.tables_db import TablesDB
from appwrite.services.teams import Teams
from appwrite.services.users import Users
from appwrite.services.account import Account
from appwrite.query import Query
import json
import os
from datetime import datetime, timedelta, timezone

DATABASE_ID = "tr_database"
USERS_COLLECTION_ID = "users_profiles"
AUDIT_LOGS_COLLECTION_ID = "audit_logs"
ADMINS_TEAM_ID = "tr-admins"


def _client(context) -> Client:
    """Create a server client using the function's execution-scoped key.

    Appwrite documents the ephemeral key in APPWRITE_FUNCTION_API_KEY at build
    time and in x-appwrite-key at execution time. This function runs server-side,
    so the request header is the authoritative runtime credential and avoids
    depending on an environment variable that is absent in this deployment.
    """
    headers = context.req.headers or {}
    api_key = str(
        headers.get("x-appwrite-key", "")
        or headers.get("X-Appwrite-Key", "")
    ).strip()
    if not api_key:
        raise RuntimeError("Appwrite function execution key is missing")

    client = Client()
    client.set_endpoint(os.environ.get("APPWRITE_FUNCTION_API_ENDPOINT") or os.environ.get("APPWRITE_ENDPOINT") or "https://fra.cloud.appwrite.io/v1")
    client.set_project(os.environ.get("APPWRITE_FUNCTION_PROJECT_ID") or os.environ.get("APPWRITE_PROJECT_ID", "trace-raffine"))
    client.set_key(api_key)
    return client



def _register_user(context, tables_db, users, body):
    import re

    email = str(body.get("email", "")).strip().lower()
    password = str(body.get("password", ""))
    name = str(body.get("name", "")).strip()
    phone = str(body.get("phone", "")).strip()
    role = str(body.get("role", "")).strip().lower()

    if not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", email):
        return context.res.json({"success": False, "code": "invalid_email", "message": "صيغة البريد الإلكتروني غير صحيحة."}, 400)
    if len(password) < 8:
        return context.res.json({"success": False, "code": "weak_password", "message": "كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل."}, 400)
    if not name:
        return context.res.json({"success": False, "code": "invalid_name", "message": "الاسم الكامل مطلوب."}, 400)
    if not re.fullmatch(r"\+[1-9][0-9]{6,14}", phone):
        return context.res.json({"success": False, "code": "invalid_phone", "message": "رقم الهاتف غير صحيح."}, 400)
    if role not in {"customer", "designer"}:
        return context.res.json({"success": False, "code": "invalid_role", "message": "نوع الحساب غير صالح."}, 400)

    user_id = ""
    try:
        created = users.create(
            user_id="unique()",
            email=email,
            phone=phone,
            password=password,
            name=name,
        )
        user_id = str(created["$id"])
        profile = tables_db.create_row(
            database_id=DATABASE_ID,
            table_id=USERS_COLLECTION_ID,
            row_id=user_id,
            data={
                "user_id": user_id,
                "email": email,
                "full_name": name,
                "phone": phone,
                "role": role,
                "created_at": datetime.now(timezone.utc).isoformat(),
                "is_suspended": False,
                "suspension_type": "none",
            },
            permissions=[
                'read("user:' + user_id + '")',
                'update("user:' + user_id + '")',
                'delete("user:' + user_id + '")',
            ],
        )
        return context.res.json({
            "success": True,
            "userId": user_id,
            "email": email,
            "name": name,
            "phone": phone,
            "role": role,
            "profileId": profile["$id"],
        }, 201)
    except Exception as error:
        if user_id:
            try:
                users.delete(user_id=user_id)
            except Exception as rollback_error:
                context.log(f"REGISTRATION ROLLBACK FAILED user={user_id}: {rollback_error}")
        lowered = str(error).lower()
        if "already exists" in lowered or "user with the same" in lowered:
            code = "phone_already_exists" if "phone" in lowered else "email_already_exists"
            message = "رقم الهاتف مستخدم مسبقاً في حساب آخر." if code == "phone_already_exists" else "البريد الإلكتروني مستخدم مسبقاً في حساب آخر."
            return context.res.json({"success": False, "code": code, "message": message}, 409)
        context.log(f"REGISTRATION FAILED user={user_id}: {error}")
        return context.res.json({"success": False, "code": "registration_failed", "message": "تعذر إنشاء الحساب حالياً."}, 500)


def _user_id(context) -> str:
    headers = context.req.headers or {}

    for key in ("x-appwrite-user-id", "X-Appwrite-User-Id"):
        value = str(headers.get(key, "")).strip()
        if value:
            return value

    return ""


def _verified_user_id(context) -> str:
    """Resolve the authenticated Appwrite user from the forwarded user JWT.

    The function may be invoked through the Appwrite gateway without a team
    execution restriction, but every request is still cryptographically tied
    to its active Appwrite session before the server-side admin check runs.
    """
    headers = context.req.headers or {}
    jwt = str(
        headers.get("x-appwrite-user-jwt", "")
        or headers.get("X-Appwrite-User-JWT", "")
    ).strip()
    if not jwt:
        return ""

    try:
        client = Client()
        client.set_endpoint(
            os.environ.get("APPWRITE_FUNCTION_API_ENDPOINT")
            or os.environ.get("APPWRITE_ENDPOINT")
            or "https://fra.cloud.appwrite.io/v1"
        )
        client.set_project(
            os.environ.get("APPWRITE_FUNCTION_PROJECT_ID")
            or os.environ.get("APPWRITE_PROJECT_ID", "trace-raffine")
        )
        client.set_jwt(jwt)
        user = Account(client).get()
        return str(user.get("$id", "")).strip()
    except Exception as error:
        context.log(f"USER JWT VERIFICATION FAILED: {error}")
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


def _parse_datetime(value):
    if not value:
        return None
    try:
        return datetime.fromisoformat(str(value).replace("Z", "+00:00"))
    except Exception:
        return None


def _effective_suspension(data, auth_enabled=True):
    suspension_type = str(data.get("suspension_type", "none") or "none").strip().lower()
    suspended_until = _parse_datetime(data.get("suspended_until"))
    if suspension_type == "temporary" and suspended_until is not None:
        if datetime.now(timezone.utc) >= suspended_until:
            return "none", False, None
    if suspension_type not in {"temporary", "permanent"}:
        suspension_type = "permanent" if bool(data.get("is_suspended", False)) or not auth_enabled else "none"
    is_suspended = suspension_type in {"temporary", "permanent"} or not auth_enabled
    return suspension_type, is_suspended, suspended_until


def _user_summary(document, auth_user=None):
    data = _doc_data(document)
    auth = auth_user or {}
    user_id = str(data.get("user_id", "") or auth.get("$id", ""))
    auth_enabled = bool(auth.get("status", True))
    suspension_type, is_suspended, suspended_until = _effective_suspension(data, auth_enabled)
    return {
        "userId": user_id,
        "name": str(data.get("full_name", "") or auth.get("name", "")),
        "email": str(data.get("email", "") or auth.get("email", "")),
        "phone": str(data.get("phone", "") or auth.get("phone", "")),
        "role": str(data.get("role", "")),
        "isSuspended": is_suspended,
        "suspensionType": suspension_type,
        "suspendedUntil": suspended_until.isoformat() if suspended_until else None,
        "isOnline": _is_recent(data.get("last_seen")),
        "lastSeen": data.get("last_seen"),
        "authEnabled": auth_enabled,
    }


def _count_collection(databases: Databases, collection_id: str, queries=None) -> int:
    result = databases.list_documents(
        database_id=DATABASE_ID,
        collection_id=collection_id,
        queries=(queries or []) + [Query.limit(1)],
    )
    if isinstance(result, dict):
        return int(result.get("total", len(result.get("documents", []))))
    return int(getattr(result, "total", len(getattr(result, "documents", []))))


def _dashboard_metrics(databases: Databases):
    return {
        "orders": _count_collection(databases, "orders"),
        "customers": _count_collection(
            databases,
            USERS_COLLECTION_ID,
            [Query.equal("role", "customer")],
        ),
        "designers": _count_collection(
            databases,
            USERS_COLLECTION_ID,
            [Query.equal("role", "designer")],
        ),
        "publishedDesigns": _count_collection(
            databases,
            "products",
            [Query.equal("status", "published")],
        ),
        "pendingDesigns": _count_collection(
            databases,
            "products",
            [Query.equal("status", "pending")],
        ),
    }


def _is_recent(value, seconds=90):
    if not value:
        return False
    try:
        from datetime import datetime, timezone
        seen = datetime.fromisoformat(str(value).replace("Z", "+00:00"))
        now = datetime.now(timezone.utc)
        return 0 <= (now - seen).total_seconds() <= seconds
    except Exception:
        return False


def _list_all_profiles(databases: Databases):
    documents = []
    offset = 0
    while True:
        result = databases.list_documents(
            database_id=DATABASE_ID,
            collection_id=USERS_COLLECTION_ID,
            queries=[Query.limit(100), Query.offset(offset)],
        )
        batch = result.get("documents", []) if isinstance(result, dict) else getattr(result, "documents", [])
        documents.extend(batch)
        total = int(result.get("total", len(documents))) if isinstance(result, dict) else int(getattr(result, "total", len(documents)))
        if not batch or len(documents) >= total:
            return documents
        offset += len(batch)


def _list_auth_users(users: Users):
    all_users = {}
    offset = 0
    while True:
        result = users.list(queries=[Query.limit(100), Query.offset(offset)])
        items = result.get("users", []) if isinstance(result, dict) else getattr(result, "users", [])
        for item in items:
            if isinstance(item, dict):
                all_users[str(item.get("$id", ""))] = item
        total = int(result.get("total", len(all_users))) if isinstance(result, dict) else int(getattr(result, "total", len(all_users)))
        if not items or len(all_users) >= total:
            return all_users
        offset += len(items)


def _list_users(databases: Databases, users: Users):
    auth_users = _list_auth_users(users)
    return [
        _user_summary(document, auth_users.get(str(_doc_data(document).get("user_id", ""))))
        for document in _list_all_profiles(databases)
    ]


def _list_designers(databases: Databases, users: Users):
    return [user for user in _list_users(databases, users) if user.get("role") == "designer"]


def _list_manager_messages(databases: Databases, user_id: str):
    sent = databases.list_documents(
        database_id=DATABASE_ID,
        collection_id="manager_messages",
        queries=[
            Query.equal("sender_id", user_id),
            Query.order_asc("created_at"),
            Query.limit(100),
        ],
    )
    received = databases.list_documents(
        database_id=DATABASE_ID,
        collection_id="manager_messages",
        queries=[
            Query.equal("recipient_id", user_id),
            Query.order_asc("created_at"),
            Query.limit(100),
        ],
    )
    messages = {}
    for document in sent.get("documents", []):
        messages[document["$id"]] = document
    for document in received.get("documents", []):
        messages[document["$id"]] = document
    ordered = list(messages.values())
    ordered.sort(key=lambda item: str(item.get("created_at", "")))
    return ordered[-100:]


def _send_manager_message(
    databases: Databases,
    admin_id: str,
    target_user_id: str,
    body: str,
):
    if not body:
        raise ValueError("Message body is required")
    if len(body) > 4000:
        raise ValueError("Message body cannot exceed 4000 characters")

    profile = databases.get_document(
        database_id=DATABASE_ID,
        collection_id=USERS_COLLECTION_ID,
        document_id=target_user_id,
    )
    profile_data = _doc_data(profile)
    role = str(profile_data.get("role", "")).strip().lower()
    if role not in {"customer", "designer"}:
        raise ValueError("Only customers and designers can receive manager messages")

    message = databases.create_document(
        database_id=DATABASE_ID,
        collection_id="manager_messages",
        document_id="unique()",
        data={
            "sender_id": admin_id,
            "recipient_id": target_user_id,
            "sender_role": "admin",
            "recipient_role": role,
            "body": body,
            "is_read": False,
            "created_at": datetime.now(timezone.utc).isoformat(),
        },
        permissions=[
            f'read("user:{target_user_id}")',
            'read("team:tr-admins")',
        ],
    )

    databases.create_document(
        database_id=DATABASE_ID,
        collection_id="notifications",
        document_id="unique()",
        data={
            "user_id": target_user_id,
            "title": "رسالة جديدة من الإدارة",
            "body": "لديك رسالة جديدة في محادثة الإدارة.",
            "is_read": False,
            "created_at": datetime.now(timezone.utc).isoformat(),
        },
        permissions=[
            f'read("user:{target_user_id}")',
        ],
    )

    return message


def _mark_manager_messages_read(databases: Databases, target_user_id: str):
    result = databases.list_documents(
        database_id=DATABASE_ID,
        collection_id="manager_messages",
        queries=[
            Query.equal("sender_id", target_user_id),
            Query.equal("recipient_role", "admin"),
            Query.limit(100),
        ],
    )
    updated = 0
    for document in result.get("documents", []):
        if not document.get("is_read", False):
            databases.update_document(
                database_id=DATABASE_ID,
                collection_id="manager_messages",
                document_id=document["$id"],
                data={"is_read": True},
            )
            updated += 1
    return updated


def _send_platform_message(databases: Databases, users: Users, admin_id: str, title: str, message_body: str, audience: str):
    title = title.strip()
    message_body = message_body.strip()
    audience = audience.strip().lower()
    if not title:
        raise ValueError("Message title is required")
    if len(title) > 200:
        raise ValueError("Message title cannot exceed 200 characters")
    if not message_body:
        raise ValueError("Message body is required")
    if len(message_body) > 1000:
        raise ValueError("Message body cannot exceed 1000 characters")
    if audience not in {"all", "customers", "designers"}:
        raise ValueError("Unsupported platform message audience")

    profiles = _list_all_profiles(databases)
    auth_users = _list_auth_users(users)
    recipients = []
    for document in profiles:
        data = _doc_data(document)
        user_id = str(data.get("user_id", "") or document.get("$id", "")).strip()
        role = str(data.get("role", "")).strip().lower()
        if not user_id or role not in {"customer", "designer"}:
            continue
        auth_user = auth_users.get(user_id, {})
        if not bool(auth_user.get("status", True)):
            continue
        if audience == "customers" and role != "customer":
            continue
        if audience == "designers" and role != "designer":
            continue
        recipients.append(user_id)

    created_at = datetime.now(timezone.utc).replace(microsecond=0).isoformat()
    created = 0
    failed = []
    for user_id in recipients:
        try:
            databases.create_document(
                database_id=DATABASE_ID,
                collection_id="notifications",
                document_id="unique()",
                data={
                    "user_id": user_id,
                    "title": title,
                    "body": message_body,
                    "is_read": False,
                    "created_at": created_at,
                },
                permissions=[f'read("user:{user_id}")'],
            )
            created += 1
        except Exception as error:
            failed.append({"userId": user_id, "error": str(error)})

    try:
        databases.create_document(
            database_id=DATABASE_ID,
            collection_id=AUDIT_LOGS_COLLECTION_ID,
            document_id="unique()",
            data={
                "user_id": admin_id,
                "action": "send_platform_message",
                "entity": "platform_notification",
                "entity_id": audience,
                "metadata_json": json.dumps(
                    {
                        "title": title,
                        "audience": audience,
                        "recipient_count": len(recipients),
                        "created_count": created,
                        "failed_count": len(failed),
                    },
                    ensure_ascii=False,
                ),
            },
        )
    except Exception as audit_error:
        pass

    return {
        "audience": audience,
        "recipientCount": len(recipients),
        "createdCount": created,
        "failedCount": len(failed),
        "createdAt": created_at,
    }


def _handle_design_approval(context, databases: Databases, user_id: str, body):
    design_id = str(body.get("designId", "")).strip()
    status = str(body.get("status", "")).strip().lower()
    feedback = str(body.get("feedback", "")).strip()

    if not design_id:
        return context.res.json({"success": False, "error": "designId is required"}, 400)
    if status not in ("approved", "rejected", "needs_revision"):
        return context.res.json({"success": False, "error": "Invalid design status"}, 400)
    if status in ("rejected", "needs_revision") and not feedback:
        return context.res.json({"success": False, "error": "feedback is required"}, 400)

    document = databases.get_document(
        database_id=DATABASE_ID,
        collection_id="products",
        document_id=design_id,
    )
    data = _doc_data(document)
    designer_id = str(
        data.get("designer_id")
        or data.get("designerId")
        or data.get("ownerId")
        or ""
    ).strip()
    if not designer_id:
        return context.res.json({"success": False, "error": "designer_id is missing on the design"}, 422)

    stored_status = "published" if status == "approved" else status
    document_permissions = [
        f'read("user:{designer_id}")',
        f'update("user:{designer_id}")',
        f'delete("user:{designer_id}")',
    ]
    if stored_status == "published":
        document_permissions = ['read("any")']

    databases.update_document(
        database_id=DATABASE_ID,
        collection_id="products",
        document_id=design_id,
        data={"status": stored_status},
        permissions=document_permissions,
    )

    try:
        databases.create_document(
            database_id=DATABASE_ID,
            collection_id="design_reviews",
            document_id="unique()",
            data={
                "design_id": design_id,
                "designer_id": designer_id,
                "status": status,
                "feedback": feedback,
                "reviewer_id": user_id,
            },
        )
    except Exception as review_error:
        context.log(f"DESIGN REVIEW LOG ERROR: {review_error}")

    return context.res.json({
        "success": True,
        "service": "admin-user-control",
        "designId": design_id,
        "status": stored_status,
        "reviewStatus": status,
    })


def _list_orders(databases: Databases):
    result = databases.list_documents(
        database_id=DATABASE_ID,
        collection_id="orders",
        queries=[
            Query.order_desc("created_at"),
            Query.limit(100),
        ],
    )
    docs = (
        result.get("documents", [])
        if isinstance(result, dict)
        else getattr(result, "documents", [])
    )
    orders = []
    for document in docs:
        data = dict(_doc_data(document))
        document_id = (
            document.get("$id", "")
            if isinstance(document, dict)
            else getattr(document, "$id", "")
        )
        data["$id"] = document_id
        orders.append(data)
    return orders


def _handle_order_status(context, databases: Databases, admin_id: str, body):
    order_id = str(body.get("orderId", "")).strip()
    status = str(body.get("status", "")).strip().lower()

    if not order_id:
        return context.res.json({"success": False, "error": "orderId is required"}, 400)
    if status not in {"pending", "paid", "processing", "completed", "cancelled"}:
        return context.res.json({"success": False, "error": "Unsupported order status"}, 400)

    order = databases.get_document(
        database_id=DATABASE_ID,
        collection_id="orders",
        document_id=order_id,
    )
    current_status = str(_doc_data(order).get("status", "")).strip().lower()
    if current_status == status:
        return context.res.json({
            "success": True,
            "service": "admin-user-control",
            "orderId": order_id,
            "status": status,
            "changed": False,
        })

    databases.update_document(
        database_id=DATABASE_ID,
        collection_id="orders",
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
                "metadata_json": json.dumps({"from": current_status, "to": status}),
            },
        )
    except Exception as audit_error:
        context.log(f"AUDIT LOG ERROR: {audit_error}")

    return context.res.json({
        "success": True,
        "service": "admin-user-control",
        "orderId": order_id,
        "status": status,
        "changed": True,
    })


def main(context):
    context.log("TR ADMIN USER CONTROL START")

    try:
        raw_body = context.req.body
        if isinstance(raw_body, str):
            try:
                body = json.loads(raw_body) if raw_body.strip() else {}
            except json.JSONDecodeError:
                body = {}
        else:
            body = raw_body if isinstance(raw_body, dict) else {}

        public_action = str(body.get("action", "")).strip().lower()
        if public_action == "register_user":
            client = _client(context)
            tables_db = TablesDB(client)
            users = Users(client)
            return _register_user(context, tables_db, users, body)

        header_user_id = _user_id(context)
        admin_id = _verified_user_id(context)

        if not admin_id:
            return context.res.json(
                {
                    "success": False,
                    "error": "Authenticated Appwrite session is required",
                },
                401,
            )

        if header_user_id and header_user_id != admin_id:
            return context.res.json(
                {
                    "success": False,
                    "error": "Authenticated user identity mismatch",
                },
                403,
            )

        client = _client(context)
        databases = Databases(client)
        teams = Teams(client)
        users = Users(client)

        context.log(f"AUTH VERIFIED USER={admin_id}")
        context.log("AUTH CHECK: testing admin team membership")
        is_admin = _is_admin(teams, admin_id)
        context.log(f"AUTH CHECK RESULT={is_admin}")
        if not is_admin:
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

        if action == "register_user":
            client = _client(context)
            tables_db = TablesDB(client)
            users = Users(client)
            return _register_user(context, tables_db, users, body)

        if action == "design_approval":
            return _handle_design_approval(context, databases, admin_id, body)

        if action == "update_order_status":
            return _handle_order_status(context, databases, admin_id, body)

        if action == "list_orders":
            context.log("LIST ORDERS: before databases.list_documents")
            return context.res.json({
                "success": True,
                "service": "admin-user-control",
                "orders": _list_orders(databases),
            })

        if action == "dashboard_metrics":
            return context.res.json({
                "success": True,
                "service": "admin-user-control",
                "metrics": _dashboard_metrics(databases),
            })

        if action == "list_manager_messages":
            target_user_id = str(body.get("userId", "")).strip()
            if not target_user_id:
                return context.res.json(
                    {"success": False, "error": "userId is required"},
                    400,
                )
            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "messages": _list_manager_messages(databases, target_user_id),
                }
            )

        if action == "send_manager_message":
            target_user_id = str(body.get("userId", "")).strip()
            message_body = str(body.get("body", "")).strip()
            if not target_user_id:
                return context.res.json(
                    {"success": False, "error": "userId is required"},
                    400,
                )
            try:
                message = _send_manager_message(
                    databases,
                    admin_id,
                    target_user_id,
                    message_body,
                )
            except ValueError as error:
                return context.res.json(
                    {"success": False, "error": str(error)},
                    400,
                )
            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "message": message,
                }
            )

        if action == "mark_manager_messages_read":
            target_user_id = str(body.get("userId", "")).strip()
            if not target_user_id:
                return context.res.json(
                    {"success": False, "error": "userId is required"},
                    400,
                )
            updated = _mark_manager_messages_read(databases, target_user_id)
            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "updated": updated,
                }
            )

        if action == "send_platform_message":
            title = str(body.get("title", "")).strip()
            message_body = str(body.get("body", "")).strip()
            audience = str(body.get("audience", "all")).strip().lower()
            try:
                result = _send_platform_message(
                    databases,
                    users,
                    admin_id,
                    title,
                    message_body,
                    audience,
                )
            except ValueError as error:
                return context.res.json(
                    {"success": False, "error": str(error)},
                    400,
                )
            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "result": result,
                }
            )

        if action == "list_users":
            user_list = _list_users(databases, users)

            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "users": user_list,
                }
            )

        if action == "list_designers":
            designers = _list_designers(databases, users)

            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "designers": designers,
                }
            )

        target_user_id = str(body.get("userId", "")).strip()

        if action not in ("suspend", "suspend_temporary", "suspend_permanent", "reactivate", "status"):
            return context.res.json(
                {
                    "success": False,
                    "error": "Unsupported user control action",
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

        # Self-protection: an administrator can never suspend or disable their own account.
        if target_user_id == admin_id:
            return context.res.json(
                {
                    "success": False,
                    "error": "Administrator accounts cannot suspend or disable themselves.",
                    "userId": target_user_id,
                    "role": "admin",
                    "selfProtection": True,
                },
                400,
            )

        doc_data = _doc_data(document)

        role = str(
            doc_data.get("role", "")
        ).strip().lower()

        if role == "admin":
            return context.res.json(
                {
                    "success": False,
                    "error": "Administrator accounts cannot be suspended from this control.",
                    "userId": target_user_id,
                    "role": role,
                },
                400,
            )

        auth_user = users.get(user_id=target_user_id)
        auth_enabled = bool(auth_user.get("status", True))
        suspension_type, current_suspended, suspended_until = _effective_suspension(
            doc_data,
            auth_enabled,
        )

        if action == "status":
            return context.res.json(
                {
                    "success": True,
                    "service": "admin-user-control",
                    "userId": target_user_id,
                    "role": role,
                    "isSuspended": current_suspended,
                    "suspensionType": suspension_type,
                    "suspendedUntil": suspended_until.isoformat() if suspended_until else None,
                    "lastSeen": doc_data.get("last_seen"),
                    "isOnline": _is_recent(doc_data.get("last_seen")),
                    "authEnabled": auth_enabled,
                }
            )

        if action == "reactivate":
            databases.update_document(
                database_id=DATABASE_ID,
                collection_id=USERS_COLLECTION_ID,
                document_id=target_user_id,
                data={
                    "is_suspended": False,
                    "suspension_type": "none",
                    "suspended_until": None,
                    "suspended_at": None,
                },
            )
            users.update_status(user_id=target_user_id, status=True)
            try:
                databases.create_document(
                    database_id=DATABASE_ID,
                    collection_id=AUDIT_LOGS_COLLECTION_ID,
                    document_id="unique()",
                    data={
                        "user_id": admin_id,
                        "action": "reactivate_user",
                        "entity": "user",
                        "entity_id": target_user_id,
                        "metadata_json": json.dumps({"role": role}),
                    },
                )
            except Exception as audit_error:
                context.log(f"AUDIT LOG ERROR: {audit_error}")
            return context.res.json({
                "success": True,
                "service": "admin-user-control",
                "userId": target_user_id,
                "role": role,
                "isSuspended": False,
                "suspensionType": "none",
                "suspendedUntil": None,
                "changed": current_suspended,
            })

        if action not in {"suspend", "suspend_temporary", "suspend_permanent"}:
            return context.res.json(
                {
                    "success": False,
                    "error": "Unsupported suspension action",
                },
                400,
            )

        requested_type = "temporary" if action == "suspend_temporary" else "permanent"
        suspended_until_value = None
        if requested_type == "temporary":
            try:
                duration_minutes = int(body.get("durationMinutes", 0))
            except (TypeError, ValueError):
                duration_minutes = 0
            if duration_minutes <= 0:
                return context.res.json(
                    {"success": False, "error": "durationMinutes must be greater than zero"},
                    400,
                )
            suspended_until_value = datetime.now(timezone.utc).replace(microsecond=0) + timedelta(minutes=duration_minutes)

        databases.update_document(
            database_id=DATABASE_ID,
            collection_id=USERS_COLLECTION_ID,
            document_id=target_user_id,
            data={
                "is_suspended": True,
                "suspension_type": requested_type,
                "suspended_until": suspended_until_value.isoformat() if suspended_until_value else None,
                "suspended_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
            },
        )

        if requested_type == "permanent":
            users.update_status(user_id=target_user_id, status=False)
        else:
            # Temporary bans keep Appwrite authentication enabled so the profile
            # can automatically become valid again when suspended_until expires.
            users.update_status(user_id=target_user_id, status=True)
        try:
            users.delete_sessions(user_id=target_user_id)
        except Exception as session_error:
            context.log(f"SESSION REVOCATION ERROR: {session_error}")

        try:
            databases.create_document(
                database_id=DATABASE_ID,
                collection_id=AUDIT_LOGS_COLLECTION_ID,
                document_id="unique()",
                data={
                    "user_id": admin_id,
                    "action": "suspend_user",
                    "entity": "user",
                    "entity_id": target_user_id,
                    "metadata_json": json.dumps(
                        {
                            "role": role,
                            "suspension_type": requested_type,
                            "duration_minutes": body.get("durationMinutes") if requested_type == "temporary" else None,
                            "suspended_until": suspended_until_value.isoformat() if suspended_until_value else None,
                        }
                    ),
                },
            )
        except Exception as audit_error:
            context.log(f"AUDIT LOG ERROR: {audit_error}")

        return context.res.json({
            "success": True,
            "service": "admin-user-control",
            "userId": target_user_id,
            "role": role,
            "isSuspended": True,
            "suspensionType": requested_type,
            "suspendedUntil": suspended_until_value.isoformat() if suspended_until_value else None,
            "changed": True,
        })

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
