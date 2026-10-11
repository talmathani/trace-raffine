import importlib.util
import json
import sys
from pathlib import Path
from unittest import TestCase, main
from unittest.mock import Mock, patch

FUNCTION_SRC = Path(__file__).resolve().parents[1] / "functions" / "admin-user-control" / "src"
sys.path.insert(0, str(FUNCTION_SRC))

import main as admin_user_control  # noqa: E402

CREATE_ORDER_SRC = Path(__file__).resolve().parents[1] / "functions" / "create-order" / "src" / "main.py"
CREATE_ORDER_SPEC = importlib.util.spec_from_file_location("create_order_function", CREATE_ORDER_SRC)
create_order_function = importlib.util.module_from_spec(CREATE_ORDER_SPEC)
CREATE_ORDER_SPEC.loader.exec_module(create_order_function)


class _FakeResponse:
    def json(self, payload, status_code=200):
        return {"payload": payload, "status_code": status_code}


class _FakeContext:
    def __init__(self):
        self.req = type("Request", (), {"headers": {}})()
        self.res = _FakeResponse()

    def log(self, *_args):
        pass


class GrantDesignAdminFileAccessTests(TestCase):
    def test_grant_preserves_designer_delete_and_adds_admin_read(self):
        context = _FakeContext()
        storage = Mock()
        storage.get_file.return_value = {
            "$permissions": [
                'read("user:designer-123")',
                'delete("user:designer-123")',
            ]
        }
        expected_permissions = [
            'read("user:designer-123")',
            'delete("user:designer-123")',
            'read("team:tr-admins")',
        ]

        with patch.object(admin_user_control, "_client", return_value=object()), patch.object(
            admin_user_control, "Storage", return_value=storage
        ):
            result = admin_user_control._handle_grant_design_admin_file_access(
                context,
                "designer-123",
                {"fileId": "file-123", "designerId": "designer-123"},
            )

        self.assertEqual(result["status_code"], 200)
        self.assertEqual(result["payload"]["permissions"], expected_permissions)
        storage.update_file.assert_called_once_with(
            bucket_id="design-files",
            file_id="file-123",
            permissions=expected_permissions,
        )

    def test_rejects_authenticated_identity_mismatch(self):
        context = _FakeContext()
        storage_constructor = Mock()

        with patch.object(admin_user_control, "Storage", storage_constructor):
            result = admin_user_control._handle_grant_design_admin_file_access(
                context,
                "different-user",
                {"fileId": "file-123", "designerId": "designer-123"},
            )

        self.assertEqual(result["status_code"], 403)
        storage_constructor.assert_not_called()

    def test_rejects_file_without_designer_read_permission(self):
        context = _FakeContext()
        storage = Mock()
        storage.get_file.return_value = {"$permissions": ['read("user:someone-else")']}

        with patch.object(admin_user_control, "_client", return_value=object()), patch.object(
            admin_user_control, "Storage", return_value=storage
        ):
            result = admin_user_control._handle_grant_design_admin_file_access(
                context,
                "designer-123",
                {"fileId": "file-123", "designerId": "designer-123"},
            )

        self.assertEqual(result["status_code"], 403)
        storage.update_file.assert_not_called()


class DesignSubmissionNotificationTests(TestCase):
    def test_submission_creates_private_admin_notification_for_designs_section(self):
        context = _FakeContext()
        databases = Mock()
        databases.get_document.return_value = {
            "data": {
                "designer_id": "designer-123",
                "status": "pending",
                "title": "New embroidery",
            }
        }
        teams = Mock()
        teams.list_memberships.return_value = {
            "memberships": [{"userId": "admin-789"}],
        }

        result = admin_user_control._handle_design_submitted(
            context, databases, teams, "designer-123", {"designId": "design-456"}
        )

        self.assertEqual(result["status_code"], 200)
        self.assertTrue(result["payload"]["success"])
        self.assertEqual(result["payload"]["designId"], "design-456")
        self.assertEqual(result["payload"]["notificationsCreated"], 1)
        notification_call = databases.create_document.call_args
        self.assertEqual(notification_call.kwargs["collection_id"], "notifications")
        self.assertEqual(
            notification_call.kwargs["data"],
            {
                "user_id": "admin-789",
                "title": "تصميم جديد يحتاج إلى مراجعة",
                "body": "وصل التصميم «New embroidery» من أحد المصممين، وهو بانتظار مراجعتك.",
                "is_read": False,
                "created_at": notification_call.kwargs["data"]["created_at"],
            },
        )
        self.assertEqual(
            notification_call.kwargs["permissions"],
            ['read("user:admin-789")'],
        )
        teams.list_memberships.assert_called_once()

    def test_submission_action_routes_before_admin_role_check(self):
        context = _FakeContext()
        context.req.headers = {"x-appwrite-user-id": "designer-123"}
        context.req.body = json.dumps({"action": "design_submitted", "designId": "design-456"})
        expected = {"payload": {"success": True, "notificationsCreated": 1}, "status_code": 200}

        with patch.object(admin_user_control, "_verified_user_id", return_value="designer-123"), patch.object(
            admin_user_control, "_client", return_value=object()
        ), patch.object(admin_user_control, "Databases", return_value=Mock()), patch.object(
            admin_user_control, "Teams", return_value=Mock()
        ), patch.object(admin_user_control, "Users", return_value=Mock()), patch.object(
            admin_user_control, "_handle_design_submitted", return_value=expected
        ) as handler, patch.object(admin_user_control, "_is_admin") as admin_check:
            result = admin_user_control.main(context)

        self.assertEqual(result, expected)
        handler.assert_called_once()
        admin_check.assert_not_called()


class DesignApprovalNotificationTests(TestCase):
    def test_rejection_creates_private_notification_with_feedback(self):
        context = _FakeContext()
        databases = Mock()
        databases.get_document.return_value = {
            "data": {
                "designer_id": "designer-123",
                "title": "Floral embroidery",
            }
        }

        result = admin_user_control._handle_design_approval(
            context,
            databases,
            "admin-123",
            {
                "designId": "design-456",
                "status": "rejected",
                "feedback": "Please revise the flower details.",
            },
        )

        self.assertEqual(result["status_code"], 200)
        self.assertTrue(result["payload"]["success"])
        self.assertTrue(result["payload"]["notificationCreated"])
        notification_call = next(
            call for call in databases.create_document.call_args_list
            if call.kwargs.get("collection_id") == "notifications"
        )
        self.assertEqual(
            notification_call.kwargs["data"],
            {
                "user_id": "designer-123",
                "title": "تحديث بشأن تصميمك",
                "body": "بعد المراجعة، لم يُعتمد التصميم «Floral embroidery». ملاحظة فريق الإدارة: Please revise the flower details.",
                "is_read": False,
                "created_at": notification_call.kwargs["data"]["created_at"],
            },
        )
        self.assertEqual(
            notification_call.kwargs["permissions"],
            ['read("user:designer-123")'],
        )

    def test_revision_request_creates_revision_notification(self):
        context = _FakeContext()
        databases = Mock()
        databases.get_document.return_value = {
            "data": {"designer_id": "designer-123", "title": "Lace motif"}
        }

        result = admin_user_control._handle_design_approval(
            context,
            databases,
            "admin-123",
            {
                "designId": "design-789",
                "status": "needs_revision",
                "feedback": "Adjust the stitch density.",
            },
        )

        self.assertTrue(result["payload"]["notificationCreated"])
        product_update = databases.update_document.call_args.kwargs
        self.assertEqual(product_update["collection_id"], "products")
        self.assertEqual(product_update["document_id"], "design-789")
        self.assertEqual(product_update["data"], {
            "status": "needs_revision",
            "rejection_reason": "Adjust the stitch density.",
        })
        notification_call = next(
            call for call in databases.create_document.call_args_list
            if call.kwargs.get("collection_id") == "notifications"
        )
        self.assertEqual(notification_call.kwargs["data"]["title"], "تصميمك يحتاج إلى بعض التعديلات")
        self.assertIn("Adjust the stitch density.", notification_call.kwargs["data"]["body"])


class ListDesignerReviewsTests(TestCase):
    def test_review_list_is_scoped_to_authenticated_designer(self):
        context = _FakeContext()
        context.req.headers = {"x-appwrite-user-id": "designer-123"}
        context.req.body = json.dumps({
            "action": "list_design_reviews",
            "userId": "designer-123",
        })
        client = Mock()
        databases = Mock()
        review = {
            "$id": "review-1",
            "design_id": "design-1",
            "designer_id": "designer-123",
            "status": "needs_revision",
            "feedback": "Adjust the stitch density.",
        }
        databases.list_documents.return_value = {"documents": [review]}

        with patch.object(create_order_function, "Client", return_value=client), patch.object(
            create_order_function, "Databases", return_value=databases
        ):
            result = create_order_function.main(context)

        self.assertEqual(result["status_code"], 200)
        self.assertTrue(result["payload"]["success"])
        self.assertEqual(result["payload"]["reviews"], [review])
        databases.list_documents.assert_called_once_with(
            database_id="tr_database",
            collection_id="design_reviews",
            queries=[
                'equal("designer_id", "designer-123")',
                'orderDesc("$createdAt")',
                "limit(100)",
            ],
        )

    def test_review_list_falls_back_to_reviews_linked_to_owned_designs(self):
        context = _FakeContext()
        context.req.headers = {"x-appwrite-user-id": "designer-123"}
        context.req.body = json.dumps({
            "action": "list_design_reviews",
            "userId": "designer-123",
        })
        client = Mock()
        databases = Mock()
        legacy_review = {
            "$id": "legacy-review",
            "design_id": "owned-design",
            "status": "needs_revision",
            "feedback": "Adjust the neckline.",
            "$createdAt": "2026-10-11T12:00:00.000Z",
        }
        databases.list_documents.side_effect = [
            {"documents": []},
            {"documents": [{"$id": "owned-design", "designer_id": "designer-123"}]},
            {"documents": [legacy_review]},
        ]

        with patch.object(create_order_function, "Client", return_value=client), patch.object(
            create_order_function, "Databases", return_value=databases
        ):
            result = create_order_function.main(context)

        self.assertEqual(result["status_code"], 200)
        self.assertEqual(result["payload"]["reviews"], [legacy_review])
        self.assertEqual(databases.list_documents.call_count, 3)


if __name__ == "__main__":
    main()
