import 'package:shop_app_ecommerce/features/auth/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserModel Tests', () {
    test('fromMap parses valid DummyJSON auth response correctly', () {
      final json = {
        'id': 1,
        'username': 'emilys',
        'email': 'emily.johnson@x.dummyjson.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'gender': 'female',
        'image': 'https://dummyjson.com/icon/emilys/128',
        'role': 'admin',
      };

      final user = UserModel.fromMap(json);

      expect(user.id, 1);
      expect(user.username, 'emilys');
      expect(user.email, 'emily.johnson@x.dummyjson.com');
      expect(user.firstName, 'Emily');
      expect(user.lastName, 'Johnson');
      expect(user.gender, 'female');
      expect(user.image, 'https://dummyjson.com/icon/emilys/128');
      expect(user.fullName, 'Emily Johnson');
      expect(user.initials, 'EJ');
      expect(user.role, 'admin');
    });

    test('fromMap handles missing or empty values gracefully', () {
      final user = UserModel.fromMap({});

      expect(user.id, 0);
      expect(user.username, '');
      expect(user.email, '');
      expect(user.firstName, '');
      expect(user.lastName, '');
      expect(user.fullName, '');
      expect(user.initials, 'U');
    });

    test('initials falls back to username if names are empty', () {
      final user = UserModel(
        id: 1,
        username: 'coder42',
        email: 'test@example.com',
        firstName: '',
        lastName: '',
        gender: 'male',
        image: '',
      );

      expect(user.initials, 'C');
    });

    test('toMap converts user model back to map accurately', () {
      final user = UserModel(
        id: 2,
        username: 'michaelw',
        email: 'michael.williams@x.dummyjson.com',
        firstName: 'Michael',
        lastName: 'Williams',
        gender: 'male',
        image: 'https://dummyjson.com/icon/michaelw/128',
        role: 'user',
      );

      final map = user.toMap();

      expect(map['id'], 2);
      expect(map['username'], 'michaelw');
      expect(map['email'], 'michael.williams@x.dummyjson.com');
      expect(map['firstName'], 'Michael');
      expect(map['lastName'], 'Williams');
      expect(map['role'], 'user');
    });

    test('copyWith updates specified fields only', () {
      final user = UserModel(
        id: 1,
        username: 'emilys',
        email: 'emily@example.com',
        firstName: 'Emily',
        lastName: 'Johnson',
        gender: 'female',
        image: 'https://dummyjson.com/icon/emilys/128',
      );

      final updated = user.copyWith(firstName: 'Emma');

      expect(updated.id, 1);
      expect(updated.firstName, 'Emma');
      expect(updated.lastName, 'Johnson');
      expect(updated.fullName, 'Emma Johnson');
    });

    test('equality and hashCode are based on id and username', () {
      final user1 = UserModel(
        id: 1,
        username: 'emilys',
        email: 'email1@example.com',
        firstName: 'Emily',
        lastName: 'Johnson',
        gender: 'female',
        image: '',
      );

      final user2 = UserModel(
        id: 1,
        username: 'emilys',
        email: 'email2@example.com',
        firstName: 'Emily',
        lastName: 'Different',
        gender: 'female',
        image: '',
      );

      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });
  });
}
