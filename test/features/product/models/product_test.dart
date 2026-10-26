import 'package:shop_app_ecommerce/features/product/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Product Model Tests', () {
    test('fromMap parses valid JSON correctly', () {
      final json = {
        'id': 1,
        'title': 'iPhone 15',
        'description': 'Latest iPhone',
        'category': 'smartphones',
        'price': 999.99,
        'discountPercentage': 10.5,
        'rating': 4.8,
        'stock': 50,
        'sold': 120,
        'tags': ['apple', 'smartphone'],
        'brand': 'Apple',
        'sku': 'IPH-15-128',
        'weight': 171,
        'dimensions': {
          'width': 7.16,
          'height': 14.76,
          'depth': 0.78,
        },
        'warrantyInformation': '1 year warranty',
        'shippingInformation': 'Free shipping',
        'availabilityStatus': 'In Stock',
        'reviews': [
          {
            'rating': 5,
            'comment': 'Awesome phone!',
            'date': '2026-01-15T10:00:00.000Z',
            'reviewerName': 'John Doe',
            'reviewerEmail': 'john@example.com',
          }
        ],
        'returnPolicy': '30-day return policy',
        'minimumOrderQuantity': 1,
        'meta': {
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-10T00:00:00.000Z',
          'barcode': '1234567890',
          'qrCode': 'https://example.com/qr',
        },
        'images': ['https://example.com/img1.png'],
        'thumbnail': 'https://example.com/thumb.png',
        'isFavourite': true,
        'colors': ['black', 'blue'],
        'sizes': ['128GB', '256GB'],
      };

      final product = Product.fromMap(json);

      expect(product.id, 1);
      expect(product.title, 'iPhone 15');
      expect(product.price, 999.99);
      expect(product.rating, 4.8);
      expect(product.tags, ['apple', 'smartphone']);
      expect(product.reviews.length, 1);
      expect(product.reviews.first.comment, 'Awesome phone!');
      expect(product.reviews.first.rating, 5);
      expect(product.reviews.first.date, isNotNull);
      expect(product.dimensions?.width, 7.16);
      expect(product.meta?.barcode, '1234567890');
      expect(product.isFavourite, true);
    });

    test('fromMap gracefully handles empty/null/missing JSON values without crashing', () {
      final json = <String, dynamic>{};

      final product = Product.fromMap(json);

      expect(product.id, 0);
      expect(product.title, '');
      expect(product.description, '');
      expect(product.category, '');
      expect(product.price, 0.0);
      expect(product.discountPercentage, 0.0);
      expect(product.rating, 0.0);
      expect(product.stock, 0);
      expect(product.sold, 0);
      expect(product.tags, isEmpty);
      expect(product.images, isEmpty);
      expect(product.reviews, isEmpty);
      expect(product.colors, isEmpty);
      expect(product.sizes, isEmpty);
      expect(product.dimensions, isNull);
      expect(product.meta, isNull);
      expect(product.isFavourite, false);
      expect(product.thumbnail, '');
      expect(product.brand, '');
    });

    test('fromMap safely converts int to double for numeric fields', () {
      final json = {
        'id': 10,
        'title': 'Test Item',
        'price': 100, // integer from API instead of double
        'rating': 4,  // integer from API instead of double
        'discountPercentage': 15,
      };

      final product = Product.fromMap(json);

      expect(product.price, 100.0);
      expect(product.rating, 4.0);
      expect(product.discountPercentage, 15.0);
    });

    test('Review handles null date or invalid date string without throwing', () {
      final reviewNullDate = Review.fromMap({
        'rating': 5,
        'comment': 'Good',
        'date': null,
      });
      expect(reviewNullDate.date, isNull);

      final reviewInvalidDate = Review.fromMap({
        'rating': 5,
        'comment': 'Good',
        'date': 'not-a-real-date',
      });
      expect(reviewInvalidDate.date, isNull);
    });

    test('copyWith preserves existing fields and overrides specified ones', () {
      const product = Product(
        id: 1,
        title: 'Original Title',
        price: 50.0,
      );

      final updated = product.copyWith(
        title: 'New Title',
        price: 75.0,
        isFavourite: true,
      );

      expect(updated.id, 1);
      expect(updated.title, 'New Title');
      expect(updated.price, 75.0);
      expect(updated.isFavourite, true);
    });

    test('Equality and hashCode are based on Product ID', () {
      const p1 = Product(id: 42, title: 'Item 1');
      const p2 = Product(id: 42, title: 'Item 1 Updated');
      const p3 = Product(id: 99, title: 'Item 1');

      expect(p1, equals(p2));
      expect(p1.hashCode, equals(p2.hashCode));
      expect(p1, isNot(equals(p3)));
    });

    test('Round-trip serialization toMap and fromMap works seamlessly', () {
      const original = Product(
        id: 7,
        title: 'Watch',
        price: 199.99,
        tags: ['tech', 'wearable'],
        dimensions: Dimensions(width: 4.0, height: 4.0, depth: 1.0),
      );

      final map = original.toMap();
      final reconstructed = Product.fromMap(map);

      expect(reconstructed.id, original.id);
      expect(reconstructed.title, original.title);
      expect(reconstructed.price, original.price);
      expect(reconstructed.tags, original.tags);
      expect(reconstructed.dimensions?.width, 4.0);
    });
  });
}
