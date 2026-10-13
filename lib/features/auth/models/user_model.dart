class UserModel {
  final int id;
  final String userName;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String image;
  final String? phone;
  final String? role;

  const UserModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.image,
    this.phone,
    this.role,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last'.isNotEmpty ? '$first$last' : userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      userName: map['userName']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      firstName: map['firstName']?.toString() ?? '',
      lastName: map['lastName']?.toString() ?? '',
      gender: map['gender']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      phone: map['phone']?.toString(),
      role: map['role']?.toString(),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'image': image,
      'phone': ?phone,
      'role': ?role,
    };
  }

  UserModel copyWith({
    int? id,
    String? userName,
    String? email,
    String? firstName,
    String? lastName,
    String? gender,
    String? image,
    String? phone,
    String? role,
  }) {
    return UserModel(
        id: id ?? this.id,
        userName: userName ?? this.userName,
        email: email ?? this.email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        gender: gender ?? this.gender,
        image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    if(identical(this, other)) return true;
    return other is UserModel && other.id == id && other.userName == userName;
  }

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode ^ userName.hashCode;
}