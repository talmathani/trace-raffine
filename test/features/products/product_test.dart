import 'package:flutter_test/flutter_test.dart';
import 'package:trace_raffine/features/products/domain/entities/product.dart';

void main() {
  group('Product', () {
    test('should create product with default values', () {
      final product = Product(
        designerId: 'designer1',
        title: 'Test Product',
        price: 99.99,
      );

      expect(product.designerId, 'designer1');
      expect(product.title, 'Test Product');
      expect(product.price, 99.99);
      expect(product.status, ProductStatus.draft);
      expect(product.salesCount, 0);
      expect(product.rating, 0);
    });

    test('should convert toJson correctly', () {
      final product = Product(
        designerId: 'd1',
        title: 'Test',
        price: 50.0,
      );

      final json = product.toJson();
      expect(json['designer_id'], 'd1');
      expect(json['title'], 'Test');
      expect(json['price'], 50.0);
      expect(json['status'], 'draft');
    });

    test('should parse fromJson correctly', () {
      final json = {
        '\$id': 'prod1',
        'designer_id': 'd1',
        'title': 'Test',
        'price': 75.5,
        'status': 'published',
        'sales_count': 10,
        'rating': 4.5,
      };

      final product = Product.fromJson(json);
      expect(product.id, 'prod1');
      expect(product.title, 'Test');
      expect(product.price, 75.5);
      expect(product.status, ProductStatus.published);
      expect(product.salesCount, 10);
      expect(product.rating, 4.5);
    });
  });
}
