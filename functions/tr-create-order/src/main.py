import json
import os
from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.services.tokens import Tokens
from appwrite.id import ID
from datetime import datetime, timedelta, timezone


def _authenticated_user_id(context) -> str:
    headers = context.req.headers or {}
    for key in ('x-appwrite-user-id', 'X-Appwrite-User-Id'):
        value = str(headers.get(key, '')).strip()
        if value:
            return value
    return ''


def main(context):
    try:
        client = Client()
        client.set_endpoint(
            os.environ.get(
                'APPWRITE_FUNCTION_API_ENDPOINT',
                os.environ.get('APPWRITE_ENDPOINT', 'https://fra.cloud.appwrite.io/v1'),
            )
        )
        project_id = os.environ.get('APPWRITE_FUNCTION_PROJECT_ID') or os.environ.get('APPWRITE_PROJECT_ID')
        client.set_project(project_id)
        client.set_key(os.environ.get('APPWRITE_API_KEY'))

        databases = Databases(client)
        tokens = Tokens(client)
        database_id = 'tr_database'
        design_files_bucket_id = 'design-files'

        raw_body = context.req.body
        if isinstance(raw_body, bytes):
            raw_body = raw_body.decode('utf-8', errors='strict')
        if isinstance(raw_body, dict):
            payload = raw_body
        else:
            try:
                normalized_body = str(raw_body).lstrip('\ufeff').strip()
                payload = json.loads(normalized_body) if normalized_body else {}
                if isinstance(payload, str):
                    payload = json.loads(payload)
            except (TypeError, ValueError):
                return context.res.json({
                    'success': False,
                    'error': 'Request body must be valid JSON',
                }, 400)
        if not isinstance(payload, dict):
            return context.res.json({
                'success': False,
                'error': 'Request body must be a JSON object',
            }, 400)

        action = str(payload.get('action', 'create_order')).strip().lower()

        requested_user_id = str(payload.get('userId', '')).strip()
        user_id = _authenticated_user_id(context)
        items = payload.get('items', [])

        if not user_id and action != 'complete_paid_order':
            return context.res.json({
                'success': False,
                'error': 'Authenticated user is required',
            }, 401)

        if requested_user_id and requested_user_id != user_id:
            return context.res.json({
                'success': False,
                'error': 'Authenticated user does not match userId',
            }, 403)

        if action == 'list_cart_items':
            result = databases.list_documents(
                database_id=database_id,
                collection_id='cart_items',
                queries=[
                    f'equal("user_id", "{user_id}")',
                    'orderDesc("$createdAt")',
                    'limit(100)',
                ],
            )
            return context.res.json({
                'success': True,
                'items': result.get('documents', []),
            })

        if action == 'add_cart_item':
            product_id = str(payload.get('productId', '')).strip()
            quantity = payload.get('quantity', 1)
            if (
                not product_id
                or not isinstance(quantity, int)
                or isinstance(quantity, bool)
                or quantity < 1
                or quantity > 999
            ):
                return context.res.json({
                    'success': False,
                    'error': 'productId and a quantity from 1 to 999 are required',
                }, 400)

            product = databases.get_document(
                database_id=database_id,
                collection_id='products',
                document_id=product_id,
            )
            if product.get('status') != 'published':
                return context.res.json({
                    'success': False,
                    'error': 'Product is not published',
                }, 409)

            existing = databases.list_documents(
                database_id=database_id,
                collection_id='cart_items',
                queries=[
                    f'equal("user_id", "{user_id}")',
                    f'equal("product_id", "{product_id}")',
                    'limit(1)',
                ],
            ).get('documents', [])

            if existing:
                document = existing[0]
                current_quantity = int(document.get('quantity', 1))
                new_quantity = min(999, current_quantity + quantity)
                item = databases.update_document(
                    database_id=database_id,
                    collection_id='cart_items',
                    document_id=document['$id'],
                    data={'quantity': new_quantity},
                )
            else:
                item = databases.create_document(
                    database_id=database_id,
                    collection_id='cart_items',
                    document_id=ID.unique(),
                    data={
                        'user_id': user_id,
                        'product_id': product_id,
                        'quantity': quantity,
                        'created_at': datetime.now(timezone.utc).isoformat(),
                    },
                    permissions=[
                        f'read("user:{user_id}")',
                        f'update("user:{user_id}")',
                        f'delete("user:{user_id}")',
                    ],
                )

            return context.res.json({
                'success': True,
                'item': item,
            })

        if action == 'update_cart_item':
            cart_item_id = str(payload.get('cartItemId', '')).strip()
            quantity = payload.get('quantity')
            if (
                not cart_item_id
                or not isinstance(quantity, int)
                or isinstance(quantity, bool)
                or quantity < 1
                or quantity > 999
            ):
                return context.res.json({
                    'success': False,
                    'error': 'cartItemId and a quantity from 1 to 999 are required',
                }, 400)

            item = databases.get_document(
                database_id=database_id,
                collection_id='cart_items',
                document_id=cart_item_id,
            )
            if item.get('user_id') != user_id:
                return context.res.json({
                    'success': False,
                    'error': 'Cart item does not belong to authenticated user',
                }, 403)

            updated = databases.update_document(
                database_id=database_id,
                collection_id='cart_items',
                document_id=cart_item_id,
                data={'quantity': quantity},
            )
            return context.res.json({
                'success': True,
                'item': updated,
            })

        if action == 'remove_cart_item':
            cart_item_id = str(payload.get('cartItemId', '')).strip()
            if not cart_item_id:
                return context.res.json({
                    'success': False,
                    'error': 'cartItemId is required',
                }, 400)

            item = databases.get_document(
                database_id=database_id,
                collection_id='cart_items',
                document_id=cart_item_id,
            )
            if item.get('user_id') != user_id:
                return context.res.json({
                    'success': False,
                    'error': 'Cart item does not belong to authenticated user',
                }, 403)

            databases.delete_document(
                database_id=database_id,
                collection_id='cart_items',
                document_id=cart_item_id,
            )
            return context.res.json({
                'success': True,
                'cartItemId': cart_item_id,
                'deleted': True,
            })

        if action == 'clear_cart':
            deleted = 0
            while True:
                result = databases.list_documents(
                    database_id=database_id,
                    collection_id='cart_items',
                    queries=[
                        f'equal("user_id", "{user_id}")',
                        'limit(100)',
                    ],
                )
                documents = result.get('documents', [])
                if not documents:
                    break
                for document in documents:
                    databases.delete_document(
                        database_id=database_id,
                        collection_id='cart_items',
                        document_id=document['$id'],
                    )
                    deleted += 1

            return context.res.json({
                'success': True,
                'deleted': deleted,
            })

        if action == 'list_notifications':
            result = databases.list_documents(
                database_id=database_id,
                collection_id='notifications',
                queries=[
                    f'equal("user_id", "{user_id}")',
                    'orderDesc("created_at")',
                    'limit(100)',
                ],
            )
            return context.res.json({
                'success': True,
                'notifications': result.get('documents', []),
            })

        if action == 'mark_notification_read':
            notification_id = str(payload.get('notificationId', '')).strip()
            if not notification_id:
                return context.res.json({
                    'success': False,
                    'error': 'notificationId is required',
                }, 400)
            notification = databases.get_document(
                database_id=database_id,
                collection_id='notifications',
                document_id=notification_id,
            )
            notification_data = notification.get('data', notification)
            if notification_data.get('user_id') != user_id:
                return context.res.json({
                    'success': False,
                    'error': 'Notification does not belong to authenticated user',
                }, 403)
            databases.update_document(
                database_id=database_id,
                collection_id='notifications',
                document_id=notification_id,
                data={'is_read': True},
            )
            return context.res.json({
                'success': True,
                'notificationId': notification_id,
            })

        if action == 'mark_all_notifications_read':
            result = databases.list_documents(
                database_id=database_id,
                collection_id='notifications',
                queries=[
                    f'equal("user_id", "{user_id}")',
                    'limit(100)',
                ],
            )
            updated = 0
            for document in result.get('documents', []):
                notification_data = document.get('data', document)
                if not notification_data.get('is_read', False):
                    notification_id = document.get('$id', '')
                    if notification_id:
                        databases.update_document(
                            database_id=database_id,
                            collection_id='notifications',
                            document_id=notification_id,
                            data={'is_read': True},
                        )
                        updated += 1
            return context.res.json({
                'success': True,
                'updated': updated,
            })

        if action == 'list_orders':
            result = databases.list_documents(
                database_id=database_id,
                collection_id='orders',
                queries=[
                    f'equal("user_id", "{user_id}")',
                    'orderDesc("created_at")',
                    'limit(100)',
                ],
            )
            return context.res.json({
                'success': True,
                'orders': result.get('documents', []),
            })

        if action == 'get_order':
            order_id = str(payload.get('orderId', '')).strip()
            if not order_id:
                return context.res.json({
                    'success': False,
                    'error': 'orderId is required',
                }, 400)
            order = databases.get_document(
                database_id=database_id,
                collection_id='orders',
                document_id=order_id,
            )
            order_data = order.get('data', order)
            if order_data.get('user_id') != user_id and order_data.get('customerId') != user_id:
                return context.res.json({
                    'success': False,
                    'error': 'Order does not belong to authenticated user',
                }, 403)
            return context.res.json({
                'success': True,
                'order': order,
            })

        if action == 'list_purchases':
            result = databases.list_documents(
                database_id=database_id,
                collection_id='purchases',
                queries=[
                    f'equal("user_id", "{user_id}")',
                    'orderDesc("purchased_at")',
                    'limit(100)',
                ],
            )
            return context.res.json({
                'success': True,
                'purchases': result.get('documents', []),
            })

        if action == 'list_reviews':
            product_id = str(payload.get('productId', '')).strip()
            if not product_id:
                return context.res.json({
                    'success': False,
                    'error': 'productId is required',
                }, 400)
            result = databases.list_documents(
                database_id=database_id,
                collection_id='reviews',
                queries=[
                    f'equal("product_id", "{product_id}")',
                    'orderDesc("created_at")',
                    'limit(100)',
                ],
            )
            reviews = []
            for document in result.get('documents', []):
                reviews.append(document)
            return context.res.json({
                'success': True,
                'reviews': reviews,
            })

        if action == 'delete_review':
            review_id = str(payload.get('reviewId', '')).strip()
            if not review_id:
                return context.res.json({
                    'success': False,
                    'error': 'reviewId is required',
                }, 400)
            review = databases.get_document(
                database_id=database_id,
                collection_id='reviews',
                document_id=review_id,
            )
            review_data = review.get('data', review)
            if review_data.get('user_id') != user_id:
                return context.res.json({
                    'success': False,
                    'error': 'Review does not belong to authenticated user',
                }, 403)
            product_id = str(review_data.get('product_id', '')).strip()
            databases.delete_document(
                database_id=database_id,
                collection_id='reviews',
                document_id=review_id,
            )
            if product_id:
                reviews = databases.list_documents(
                    database_id=database_id,
                    collection_id='reviews',
                    queries=[
                        f'equal("product_id", "{product_id}")',
                        'limit(100)',
                    ],
                ).get('documents', [])
                review_count = len(reviews)
                average = (
                    sum(int(item.get('rating', 0)) for item in reviews) / review_count
                    if review_count
                    else 0
                )
                databases.update_document(
                    database_id=database_id,
                    collection_id='products',
                    document_id=product_id,
                    data={
                        'review_count': review_count,
                        'rating': round(average),
                    },
                )
            return context.res.json({
                'success': True,
                'reviewId': review_id,
                'deleted': True,
            })

        if action == 'get_purchased_file':
            product_id = str(payload.get('productId', '')).strip()
            if not product_id:
                return context.res.json({
                    'success': False,
                    'error': 'productId is required',
                }, 400)

            purchase_result = databases.list_documents(
                database_id=database_id,
                collection_id='purchases',
                queries=[
                    f'equal("user_id", "{user_id}")',
                    f'equal("product_id", "{product_id}")',
                    'limit(1)',
                ],
            )
            if not purchase_result.get('documents'):
                return context.res.json({
                    'success': False,
                    'error': 'Purchase required before downloading this design',
                }, 403)

            product = databases.get_document(
                database_id=database_id,
                collection_id='products',
                document_id=product_id,
            )
            file_id = str(product.get('file_key', '')).strip()
            if not file_id:
                return context.res.json({
                    'success': False,
                    'error': 'Purchased design file is unavailable',
                }, 404)

            token = tokens.create_file_token(
                bucket_id=design_files_bucket_id,
                file_id=file_id,
                expire=(datetime.now(timezone.utc) + timedelta(hours=1)).isoformat(),
            )
            secret = str(
                getattr(token, 'secret', '')
                or (token.get('secret', '') if isinstance(token, dict) else '')
            ).strip()
            if not secret:
                return context.res.json({
                    'success': False,
                    'error': 'Could not create a secure download token',
                }, 500)

            endpoint = os.environ.get(
                'APPWRITE_FUNCTION_API_ENDPOINT',
                os.environ.get('APPWRITE_ENDPOINT', 'https://fra.cloud.appwrite.io/v1'),
            ).rstrip('/')
            download_url = (
                f'{endpoint}/storage/buckets/{design_files_bucket_id}/files/'
                f'{file_id}/download?project={project_id}&token={secret}'
            )
            return context.res.json({
                'success': True,
                'productId': product_id,
                'fileId': file_id,
                'downloadUrl': download_url,
                'expiresAt': getattr(token, 'expire', None) or (token.get('expire') if isinstance(token, dict) else None),
            })

        if action == 'complete_paid_order':
            webhook_secret = str(os.environ.get('TR_PAYMENT_WEBHOOK_SECRET', '')).strip()
            provided_secret = str((context.req.headers or {}).get('x-tr-payment-webhook-secret', '')).strip()
            if not webhook_secret or provided_secret != webhook_secret:
                return context.res.json({
                    'success': False,
                    'error': 'Payment confirmation is not authorized',
                }, 401)

            order_id = str(payload.get('orderId', '')).strip()
            transaction_id = str(payload.get('transactionId', '')).strip()
            if not order_id or not transaction_id:
                return context.res.json({
                    'success': False,
                    'error': 'orderId and transactionId are required',
                }, 400)

            order = databases.get_document(
                database_id=database_id,
                collection_id='orders',
                document_id=order_id,
            )
            already_paid = str(order.get('payment_status', '')).strip().lower() == 'paid'
            customer_id = str(order.get('user_id', '')).strip()
            if not customer_id:
                return context.res.json({
                    'success': False,
                    'error': 'Order has no customer',
                }, 422)

            if not already_paid:
                databases.update_document(
                    database_id=database_id,
                    collection_id='orders',
                    document_id=order_id,
                    data={
                        'payment_status': 'paid',
                        'order_status': 'completed',
                        'completed_at': datetime.now(timezone.utc).isoformat(),
                    },
                )

            order_items = databases.list_documents(
                database_id=database_id,
                collection_id='order_items',
                queries=[
                    f'equal("order_id", "{order_id}")',
                    'limit(100)',
                ],
            ).get('documents', [])

            created_purchases = []
            for item in order_items:
                item_product_id = str(item.get('product_id', '')).strip()
                if not item_product_id:
                    continue

                existing = databases.list_documents(
                    database_id=database_id,
                    collection_id='purchases',
                    queries=[
                        f'equal("user_id", "{customer_id}")',
                        f'equal("product_id", "{item_product_id}")',
                        f'equal("order_id", "{order_id}")',
                        'limit(1)',
                    ],
                ).get('documents', [])
                if existing:
                    created_purchases.append(existing[0]['$id'])
                    continue

                purchase_doc = databases.create_document(
                    database_id=database_id,
                    collection_id='purchases',
                    document_id=ID.unique(),
                    data={
                        'user_id': customer_id,
                        'product_id': item_product_id,
                        'order_id': order_id,
                        'purchased_at': datetime.now(timezone.utc).isoformat(),
                    },
                )
                created_purchases.append(purchase_doc['$id'])

            ordered_product_ids = {
                str(item.get('product_id', '')).strip()
                for item in order_items
                if str(item.get('product_id', '')).strip()
            }
            if ordered_product_ids:
                cart_documents = databases.list_documents(
                    database_id=database_id,
                    collection_id='cart_items',
                    queries=[
                        f'equal("user_id", "{customer_id}")',
                        'limit(100)',
                    ],
                ).get('documents', [])
                for cart_document in cart_documents:
                    cart_product_id = str(cart_document.get('product_id', '')).strip()
                    if cart_product_id not in ordered_product_ids:
                        continue
                    databases.delete_document(
                        database_id=database_id,
                        collection_id='cart_items',
                        document_id=cart_document['$id'],
                    )

            return context.res.json({
                'success': True,
                'orderId': order_id,
                'transactionId': transaction_id,
                'purchaseIds': created_purchases,
                'alreadyPaid': already_paid,
            })

        if action == 'purchase_product':
            product_id = str(payload.get('productId', '')).strip()
            order_id = str(payload.get('orderId', '')).strip()
            if not product_id or not order_id:
                return context.res.json({
                    'success': False,
                    'error': 'Missing required fields',
                }, 400)

            order = databases.get_document(
                database_id=database_id,
                collection_id='orders',
                document_id=order_id,
            )
            if order.get('user_id') != user_id and order.get('customerId') != user_id:
                return context.res.json({
                    'success': False,
                    'error': 'Order does not belong to authenticated user',
                }, 403)

            if str(order.get('payment_status', '')).strip().lower() != 'paid':
                return context.res.json({
                    'success': False,
                    'error': 'Payment must be confirmed before creating a purchase',
                }, 409)

            order_items = databases.list_documents(
                database_id=database_id,
                collection_id='order_items',
                queries=[
                    f'equal("order_id", "{order_id}")',
                    f'equal("product_id", "{product_id}")',
                    'limit(1)',
                ],
            )
            if not order_items.get('documents'):
                return context.res.json({
                    'success': False,
                    'error': 'Product is not part of this order',
                }, 403)

            product = databases.get_document(
                database_id=database_id,
                collection_id='products',
                document_id=product_id,
            )
            if str(product.get('file_key', '')).strip() == '':
                return context.res.json({
                    'success': False,
                    'error': 'Design file is unavailable',
                }, 404)

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
                    'purchased_at': datetime.now(timezone.utc).isoformat(),
                },
            )
            databases.update_document(
                database_id=database_id,
                collection_id='orders',
                document_id=order_id,
                data={
                    'order_status': 'completed',
                    'payment_status': 'paid',
                    'completed_at': datetime.now(timezone.utc).isoformat(),
                },
            )
            return context.res.json({
                'success': True,
                'purchaseId': purchase_doc['$id'],
            })

        if action == 'review_product':
            product_id = str(payload.get('productId', '')).strip()
            rating = payload.get('rating')
            review_text = payload.get('reviewText', '')
            if (
                not product_id
                or not isinstance(rating, int)
                or isinstance(rating, bool)
                or rating < 1
                or rating > 5
            ):
                return context.res.json({
                    'success': False,
                    'error': 'Missing required fields',
                }, 400)

            purchases = databases.list_documents(
                database_id=database_id,
                collection_id='purchases',
                queries=[
                    f'equal("user_id", "{user_id}")',
                    f'equal("product_id", "{product_id}")',
                    'limit(1)',
                ],
            )
            if not purchases.get('documents'):
                return context.res.json({
                    'success': False,
                    'error': 'User has not purchased this product',
                }, 403)

            existing_review = databases.list_documents(
                database_id=database_id,
                collection_id='reviews',
                queries=[
                    f'equal("user_id", "{user_id}")',
                    f'equal("product_id", "{product_id}")',
                    'limit(1)',
                ],
            )
            if existing_review.get('documents'):
                return context.res.json({
                    'success': False,
                    'error': 'User has already reviewed this product',
                }, 409)

            review_doc = databases.create_document(
                database_id=database_id,
                collection_id='reviews',
                document_id=ID.unique(),
                data={
                    'user_id': user_id,
                    'product_id': product_id,
                    'rating': rating,
                    'review_text': review_text,
                    'created_at': datetime.now(timezone.utc).isoformat(),
                },
            )
            all_reviews = databases.list_documents(
                database_id=database_id,
                collection_id='reviews',
                queries=[
                    f'equal("product_id", "{product_id}")',
                    'limit(100)',
                ],
            ).get('documents', [])
            review_count = len(all_reviews)
            average = (
                sum(int(item.get('rating', 0)) for item in all_reviews) / review_count
                if review_count
                else 0
            )
            databases.update_document(
                database_id=database_id,
                collection_id='products',
                document_id=product_id,
                data={
                    'review_count': review_count,
                    'rating': round(average),
                },
            )

            return context.res.json({
                'success': True,
                'reviewId': review_doc['$id'],
            })

        if action != 'create_order':
            return context.res.json({
                'success': False,
                'error': 'Unsupported action',
            }, 400)

        currency = str(payload.get('currency', 'USD')).strip().upper() or 'USD'

        if not isinstance(items, list) or not items:
            return context.res.json({
                'success': False,
                'error': 'items must be a non-empty array',
            }, 400)

        if not user_id:
            return context.res.json({
                'success': False,
                'error': 'Missing required fields',
            })

        total_amount = 0
        product_designer_id = ''

        for item in items:
            if not isinstance(item, dict):
                return context.res.json({
                    'success': False,
                    'error': 'Each order item must be an object',
                }, 400)

            product_id = item.get('productId')
            quantity = item.get('quantity', 1)

            if not isinstance(quantity, int) or isinstance(quantity, bool) or quantity < 1:
                return context.res.json({
                    'success': False,
                    'error': 'quantity must be a positive integer',
                })

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
            if not isinstance(price, (int, float)) or isinstance(price, bool) or price < 0:
                return context.res.json({
                    'success': False,
                    'error': 'Product price is invalid',
                }, 422)
            total_amount += price * quantity
            designer_id = str(product.get('designer_id', '')).strip()
            if not designer_id:
                return context.res.json({
                    'success': False,
                    'error': 'Published product is missing designer_id',
                }, 422)
            if not product_designer_id:
                product_designer_id = designer_id
            elif designer_id != product_designer_id:
                return context.res.json({
                    'success': False,
                    'error': 'Orders must contain products from one designer',
                }, 409)

        if not product_designer_id:
            return context.res.json({
                'success': False,
                'error': 'Published product is missing designer_id',
            }, 422)

        order_doc = databases.create_document(
            database_id=database_id,
            collection_id='orders',
            document_id=ID.unique(),
            data={
                'customerId': user_id,
                'designId': items[0].get('productId'),
                'designerId': product_designer_id,
                'amount': float(total_amount),
                'user_id': user_id,
                'total_amount': int(round(total_amount)),
                'currency': currency,
                'payment_status': 'pending',
                'order_status': 'pending',
                'created_at': datetime.now(timezone.utc).isoformat(),
            },
            permissions=[
                f'read("user:{user_id}")',
                'read("team:tr-admins")',
            ],
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

