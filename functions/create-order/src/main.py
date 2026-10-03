import json
import os
from appwrite.client import Client
from appwrite.services.databases import Databases
from appwrite.id import ID
from datetime import datetime, timezone


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
        client.set_project(os.environ.get('APPWRITE_FUNCTION_PROJECT_ID') or os.environ.get('APPWRITE_PROJECT_ID'))
        client.set_key(os.environ.get('APPWRITE_API_KEY'))

        databases = Databases(client)
        database_id = 'tr_database'

        raw_body = context.req.body
        if isinstance(raw_body, bytes):
            raw_body = raw_body.decode('utf-8', errors='strict')
        try:
            payload = json.loads(raw_body) if str(raw_body).strip() else {}
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

        if not user_id:
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

        if action == 'list_manager_messages':
            result_sender = databases.list_documents(
                database_id=database_id,
                collection_id='manager_messages',
                queries=[
                    f'equal("sender_id", "{user_id}")',
                    'orderDesc("created_at")',
                    'limit(100)',
                ],
            )
            result_recipient = databases.list_documents(
                database_id=database_id,
                collection_id='manager_messages',
                queries=[
                    f'equal("recipient_id", "{user_id}")',
                    'orderDesc("created_at")',
                    'limit(100)',
                ],
            )
            messages_by_id = {}
            for document in result_sender.get('documents', []):
                messages_by_id[document['$id']] = document
            for document in result_recipient.get('documents', []):
                messages_by_id[document['$id']] = document
            messages = list(messages_by_id.values())
            messages.sort(key=lambda item: str(item.get('created_at', '')))
            return context.res.json({
                'success': True,
                'messages': messages[-100:],
            })

        if action == 'send_manager_message':
            body = str(payload.get('body', '')).strip()
            if not body:
                return context.res.json({
                    'success': False,
                    'error': 'Message body is required',
                }, 400)
            if len(body) > 4000:
                return context.res.json({
                    'success': False,
                    'error': 'Message body cannot exceed 4000 characters',
                }, 400)

            profile_result = databases.get_document(
                database_id=database_id,
                collection_id='users_profiles',
                document_id=user_id,
            )
            profile = profile_result.get('data', profile_result)
            role = str(profile.get('role', '')).strip().lower()
            if role not in {'customer', 'designer'}:
                return context.res.json({
                    'success': False,
                    'error': 'Only customers and designers can contact the manager',
                }, 403)

            message = databases.create_document(
                database_id=database_id,
                collection_id='manager_messages',
                document_id=ID.unique(),
                data={
                    'sender_id': user_id,
                    'recipient_id': 'tr-admins',
                    'sender_role': role,
                    'recipient_role': 'admin',
                    'body': body,
                    'is_read': False,
                    'created_at': datetime.now(timezone.utc).isoformat(),
                },
                permissions=[
                    f'read("user:{user_id}")',
                    'read("team:tr-admins")',
                ],
            )
            return context.res.json({
                'success': True,
                'message': message,
            })

        if action == 'mark_manager_messages_read':
            result = databases.list_documents(
                database_id=database_id,
                collection_id='manager_messages',
                queries=[
                    f'equal("recipient_id", "{user_id}")',
                    'limit(100)',
                ],
            )
            updated = 0
            for document in result.get('documents', []):
                if not document.get('is_read', False):
                    databases.update_document(
                        database_id=database_id,
                        collection_id='manager_messages',
                        document_id=document['$id'],
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
                data={'status': 'completed'},
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
                'total_amount': total_amount,
                'currency': currency,
                'payment_status': 'pending',
                'status': 'pending',
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

