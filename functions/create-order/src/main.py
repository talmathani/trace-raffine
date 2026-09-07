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
        items = payload.get('items', [])
        currency = payload.get('currency', 'USD')

        if not user_id or not items:
            return context.res.json({
                'success': False,
                'error': 'Missing required fields',
            })

        total_amount = 0

        for item in items:
            product_id = item.get('productId')
            quantity = item.get('quantity', 1)

            if not product_id:
                return context.res.json({
                    'success': False,
                    'error': 'Missing productId',
                })

            product = databases.get_document(
                database_id=database_id,
                collection_id='products',
                document_id=product_id,
            )

            if product.get('status') != 'published':
                return context.res.json({
                    'success': False,
                    'error': 'Product is not published',
                })

            price = product.get('price', 0)
            total_amount += price * quantity

        order_doc = databases.create_document(
            database_id=database_id,
            collection_id='orders',
            document_id=ID.unique(),
            data={
                'customer_id': user_id,
                'total_amount': total_amount,
                'currency': currency,
                'payment_status': 'pending',
                'status': 'pending',
                'created_at': context.req.headers.get(
                    'x-appwrite-date',
                    '',
                ),
            },
        )

        for item in items:
            product = databases.get_document(
                database_id=database_id,
                collection_id='products',
                document_id=item.get('productId'),
            )

            databases.create_document(
                database_id=database_id,
                collection_id='order_items',
                document_id=ID.unique(),
                data={
                    'order_id': order_doc['$id'],
                    'product_id': item.get('productId'),
                    'price': product.get('price', 0),
                    'quantity': item.get('quantity', 1),
                },
            )

        return context.res.json({
            'success': True,
            'orderId': order_doc['$id'],
            'totalAmount': total_amount,
        })

    except Exception as e:
        return context.res.json({
            'success': False,
            'error': str(e),
        })

