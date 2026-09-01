import json
import os
from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.id import ID

def main(context):
    try:
        client = Client()
        client.set_endpoint(os.environ.get('APPWRITE_ENDPOINT', 'https://fra.cloud.appwrite.io/v1'))
        client.set_project(os.environ.get('APPWRITE_PROJECT_ID'))
        client.set_key(os.environ.get('APPWRITE_API_KEY'))
        
        databases = Databases(client)
        database_id = 'tr_database'
        
        payload = json.loads(context.req.body)
        
        user_id = payload.get('userId')
        items = payload.get('items', [])
        currency = payload.get('currency', 'USD')
        
        if not user_id or not items:
            return context.res.json({'success': False, 'error': 'Missing required fields'})
        
        total_amount = 0
        product_ids = []
        
        for item in items:
            product_id = item.get('productId')
            quantity = item.get('quantity', 1)
            
            product = databases.get_document(
                database_id=database_id,
                collection_id='products',
                document_id=product_id
            )
            
            price = product.get('price', 0)
            total_amount += price * quantity
            product_ids.append(product_id)
        
        order_doc = databases.create_document(
            database_id=database_id,
            collection_id='orders',
            document_id=ID.unique(),
            data={
                'user_id': user_id,
                'total_amount': total_amount,
                'currency': currency,
                'payment_status': 'pending',
                'order_status': 'pending',
                'created_at': context.req.headers.get('x-appwrite-date', ''),
            }
        )
        
        for item in items:
            databases.create_document(
                database_id=database_id,
                collection_id='order_items',
                document_id=ID.unique(),
                data={
                    'order_id': order_doc['$id'],
                    'product_id': item.get('productId'),
                    'price': item.get('price', 0),
                    'quantity': item.get('quantity', 1),
                }
            )
        
        return context.res.json({
            'success': True,
            'orderId': order_doc['$id'],
            'totalAmount': total_amount,
        })
        
    except Exception as e:
        return context.res.json({'success': False, 'error': str(e)})
