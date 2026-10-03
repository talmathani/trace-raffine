import os
from datetime import datetime, timedelta, timezone
from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.services.storage import Storage

def main(context):
    client = Client().set_endpoint(os.environ.get('APPWRITE_FUNCTION_API_ENDPOINT', 'https://fra.cloud.appwrite.io/v1')).set_project(os.environ.get('APPWRITE_FUNCTION_PROJECT_ID') or os.environ.get('APPWRITE_PROJECT_ID')).set_key(os.environ.get('APPWRITE_API_KEY'))
    databases = Databases(client)
    storage = Storage(client)
    database_id = 'tr_database'
    bucket_id = 'design-files'
    cutoff = (datetime.now(timezone.utc) - timedelta(days=7)).isoformat()
    result = databases.list_documents(database_id=database_id, collection_id='manager_messages', queries=[f'lessThan("created_at", "{cutoff}")', 'limit(100)'])
    deleted = 0
    files = 0
    for document in result.get('documents', []):
        file_id = str(document.get('attachment_file_id', '')).strip()
        if file_id:
            try:
                storage.delete_file(bucket_id=bucket_id, file_id=file_id)
                files += 1
            except Exception:
                pass
        databases.delete_document(database_id=database_id, collection_id='manager_messages', document_id=document['$id'])
        deleted += 1
    return context.res.json({'success': True, 'deletedMessages': deleted, 'deletedFiles': files})
