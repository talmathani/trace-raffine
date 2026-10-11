import importlib.util
import json
import sys
from pathlib import Path
from unittest import TestCase
from unittest.mock import Mock, patch

FUNCTION_SRC = Path(__file__).resolve().parents[1] / "functions" / "tr-create-order" / "src"
sys.path.insert(0, str(FUNCTION_SRC))
SPEC = importlib.util.spec_from_file_location("active_tr_create_order", FUNCTION_SRC / "main.py")
active_function = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(active_function)


class FakeResponse:
    def json(self, payload, status_code=200):
        return {"payload": payload, "status_code": status_code}


class FakeContext:
    def __init__(self, body, user_id="designer-123"):
        self.req = type("Request", (), {
            "headers": {"x-appwrite-user-id": user_id} if user_id else {},
            "body": json.dumps(body),
        })()
        self.res = FakeResponse()


class ActiveCreateOrderManagerMessageTests(TestCase):
    def _run(self, body, databases, user_id="designer-123"):
        context = FakeContext(body, user_id=user_id)
        client = Mock()
        with patch.object(active_function, "Client", return_value=client), \
             patch.object(active_function, "Databases", return_value=databases), \
             patch.object(active_function, "Tokens", return_value=Mock()), \
             patch.dict("os.environ", {"APPWRITE_API_KEY": "test-key", "APPWRITE_FUNCTION_PROJECT_ID": "trace-raffine"}):
            result = active_function.main(context)
        return result

    def test_list_manager_messages_returns_sent_and_received_messages(self):
        databases = Mock()
        databases.list_documents.side_effect = [
            {"documents": [{"$id": "sent-1", "created_at": "2026-01-01T00:00:00Z"}]},
            {"documents": [{"$id": "received-1", "created_at": "2026-01-02T00:00:00Z"}]},
        ]
        result = self._run({"action": "list_manager_messages", "userId": "designer-123"}, databases)
        self.assertEqual(result["status_code"], 200)
        self.assertTrue(result["payload"]["success"])
        self.assertEqual([m["$id"] for m in result["payload"]["messages"]], ["sent-1", "received-1"])
        self.assertEqual(databases.list_documents.call_count, 2)

    def test_send_manager_message_uses_authenticated_designer_and_admin_team(self):
        databases = Mock()
        databases.get_document.return_value = {"data": {"role": "designer"}}
        databases.create_document.return_value = {"$id": "message-1"}
        with patch.object(active_function.ID, "unique", return_value="message-1"):
            result = self._run({"action": "send_manager_message", "userId": "designer-123", "body": "Please review my design"}, databases)
        self.assertEqual(result["status_code"], 200)
        self.assertTrue(result["payload"]["success"])
        call = databases.create_document.call_args.kwargs
        self.assertEqual(call["collection_id"], "manager_messages")
        self.assertEqual(call["data"]["sender_id"], "designer-123")
        self.assertEqual(call["data"]["recipient_id"], "tr-admins")
        self.assertEqual(call["data"]["recipient_role"], "admin")
        self.assertIn('read("team:tr-admins")', call["permissions"])

    def test_mark_manager_messages_read_updates_only_unread_received_messages(self):
        databases = Mock()
        databases.list_documents.return_value = {"documents": [
            {"$id": "unread-1", "is_read": False},
            {"$id": "read-1", "is_read": True},
        ]}
        result = self._run({"action": "mark_manager_messages_read", "userId": "designer-123"}, databases)
        self.assertEqual(result["status_code"], 200)
        self.assertEqual(result["payload"]["updated"], 1)
        databases.update_document.assert_called_once_with(
            database_id="tr_database", collection_id="manager_messages", document_id="unread-1", data={"is_read": True}
        )

    def test_rejects_body_user_id_that_differs_from_authenticated_identity(self):
        databases = Mock()
        result = self._run({"action": "list_manager_messages", "userId": "another-user"}, databases)
        self.assertEqual(result["status_code"], 403)
        self.assertFalse(result["payload"]["success"])
        databases.list_documents.assert_not_called()