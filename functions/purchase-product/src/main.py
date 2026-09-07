import json
import os
from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.id import ID

def main(context):
    try:
        client = Client()
        client.set_endpoint(
            os.environ.get(
                'APPWRITE_ENDPOINT',
                'https://fra.cloud.appwrite.io/v1',
            )
        )
        client.set_project(os.environ.get('APPWRITE_PROJECT_ID'))
        client.set_key(os.environ.get('APPWRITE_API_KEY'))

        databases = Databases(client)
        database_id = 'tr_database'

        payload = json.loads(context.req.body)

        user_id = payload.get('userId')
        product_id = payload.get('productId')
        order_id = payload.get('orderId')

        if not user_id or not product_id or not order_id:
            return context.res.json({
                'success': False,
                'error': 'Missing required fields',
            })

        existing = databases.list_documents(
            database_id=database_id,
            collection_id='purchases',
            queries=[
                f'equal("user_id", "{user_id}")',
                f'equal("product_id", "{product_id}")',
                'limit(1)',
            ],
        )

        if existing.get('documents'):
            return context.res.json({
                'success': True,
                'message': 'Already purchased',
            })

        purchase_doc = databases.create_document(
            database_id=database_id,
            collection_id='purchases',
            document_id=ID.unique(),
            data={
                'user_id': user_id,
                'product_id': product_id,
                'order_id': order_id,
                'purchased_at': context.req.headers.get(
                    'x-appwrite-date',
                    '',
                ),
            },
        )

        databases.update_document(
            database_id=database_id,
            collection_id='orders',
            document_id=order_id,
            data={'status': 'completed'},
        )

        return context.res.json({
            'success': True,
            'purchaseId': purchase_doc['$id'],
        })

    except Exception as e:
        return context.res.json({
            'success': False,
            'error': str(e),
        })
