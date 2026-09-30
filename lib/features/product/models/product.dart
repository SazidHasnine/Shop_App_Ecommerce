class Product {
  final int? id;
  final String? title;
  final String? description;
  final String? category;
  final double? price;
  final double? discountPercentage;
  final double? rating;
  final bool? isFavourite;
  final int? stock;
  final int? sold;
  final List<String>? colors;
  final List<String>? sizes;
  final List<String>? tags;
  final String? brand;
  final String? sku;
  final int? weight;
  final Dimensions? dimensions;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;
  final List<Review>? reviews;
  final String? returnPolicy;
  final int? minimumOrderQuantity;
  final Meta? meta;
  final List<String>? images;
  final String? thumbnail;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.category = '',
    this.discountPercentage = 0.0,
    this.rating = 0.0,
    this.stock = 0,
    this.tags = const [],
    this.brand = '',
    this.sku = '',
    this.weight = 0,
    this.dimensions = const Dimensions(width: 0, height: 0, depth: 0),
    this.warrantyInformation = '',
    this.shippingInformation = '',
    this.availabilityStatus = '',
    this.reviews = const [],
    this.returnPolicy = '',
    this.minimumOrderQuantity = 1,
    this.meta = const Meta(),
    this.images = const [],
    this.thumbnail = '',
    this.isFavourite = false,
    this.sold = 0,
    this.colors = const [],
    this.sizes = const [],
  });

  Product copyWith({
    int? id,
    String? title,
    String? description,
    String? category,
    double? price,
    double? discountPercentage,
    double? rating,
    int? stock,
    List<String>? tags,
    String? brand,
    String? sku,
    int? weight,
    Dimensions? dimensions,
    String? warrantyInformation,
    String? shippingInformation,
    String? availabilityStatus,
    List<Review>? reviews,
    String? returnPolicy,
    int? minimumOrderQuantity,
    Meta? meta,
    List<String>? images,
    String? thumbnail,
    bool? isFavourite,
    int? sold,
    List<String>? colors,
    List<String>? sizes,
  }) => Product(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    price: price ?? this.price,
    discountPercentage: discountPercentage ?? this.discountPercentage,
    rating: rating ?? this.rating,
    stock: stock ?? this.stock,
    tags: tags ?? this.tags,
    brand: brand ?? this.brand,
    sku: sku ?? this.sku,
    weight: weight ?? this.weight,
    dimensions: dimensions ?? this.dimensions,
    warrantyInformation: warrantyInformation ?? this.warrantyInformation,
    shippingInformation: shippingInformation ?? this.shippingInformation,
    availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    reviews: reviews ?? this.reviews,
    returnPolicy: returnPolicy ?? this.returnPolicy,
    minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
    meta: meta ?? this.meta,
    images: images ?? this.images,
    thumbnail: thumbnail ?? this.thumbnail,
    isFavourite: isFavourite ?? this.isFavourite,
    sold: sold ?? this.sold,
    colors: colors ?? this.colors,
    sizes: sizes ?? this.sizes,
  );

  factory Product.fromMap(Map<String, dynamic> json) => Product(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    category: json["category"],
    price: json["price"]?.toDouble(),
    discountPercentage: json["discountPercentage"]?.toDouble(),
    rating: json["rating"]?.toDouble(),
    stock: json["stock"],
    tags: List<String>.from((json["tags"] ?? []).map((x) => x) ?? []),
    brand: json["brand"],
    sku: json["sku"],
    weight: json["weight"],
    dimensions: Dimensions.fromMap(json["dimensions"]),
    warrantyInformation: json["warrantyInformation"],
    shippingInformation: json["shippingInformation"],
    availabilityStatus: json["availabilityStatus"],
    reviews: List<Review>.from(
      (json["reviews"] ?? []).map((x) => Review.fromMap(x)),
    ),
    returnPolicy: json["returnPolicy"],
    minimumOrderQuantity: json["minimumOrderQuantity"],
    meta: Meta.fromMap(json["meta"]),
    images: List<String>.from((json["images"] ?? []).map((x) => x)),
    thumbnail: json["thumbnail"],
    isFavourite: json["isFavourite"] ?? json["isFavourite"] ?? false,
    sold: json["sold"] ?? 0,
    colors: List<String>.from((json["colors"] ?? []).map((x) => x)),
    sizes: List<String>.from((json["sizes"] ?? []).map((x) => x)),
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "title": title,
    "description": description,
    "category": category,
    "price": price,
    "discountPercentage": discountPercentage,
    "rating": rating,
    "stock": stock,
    "tags": List<dynamic>.from(tags?.map((x) => x) ?? []),
    "brand": brand,
    "sku": sku,
    "weight": weight,
    "dimensions": dimensions?.toMap(),
    "warrantyInformation": warrantyInformation,
    "shippingInformation": shippingInformation,
    "availabilityStatus": availabilityStatus,
    "reviews": List<dynamic>.from(reviews?.map((x) => x.toMap()) ?? []),
    "returnPolicy": returnPolicy,
    "minimumOrderQuantity": minimumOrderQuantity,
    "meta": meta?.toMap(),
    "images": List<dynamic>.from(images?.map((x) => x) ?? []),
    "thumbnail": thumbnail,
    "isFavourite": isFavourite,
    "isFavourite": isFavourite,
    "sold": sold,
    "colors": List<dynamic>.from(colors?.map((x) => x) ?? []),
    "sizes": List<dynamic>.from(sizes?.map((x) => x) ?? []),
  };
}

class Dimensions {
  final double? width;
  final double? height;
  final double? depth;

  const Dimensions({
    required this.width,
    required this.height,
    required this.depth,
  });

  Dimensions copyWith({double? width, double? height, double? depth}) =>
      Dimensions(
        width: width ?? this.width,
        height: height ?? this.height,
        depth: depth ?? this.depth,
      );

  factory Dimensions.fromMap(Map<String, dynamic> json) => Dimensions(
    width: json["width"]?.toDouble(),
    height: json["height"]?.toDouble(),
    depth: json["depth"]?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    "width": width,
    "height": height,
    "depth": depth,
  };
}

class Meta {
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? barcode;
  final String? qrCode;

  const Meta({this.createdAt, this.updatedAt, this.barcode, this.qrCode});

  Meta copyWith({
    DateTime? createdAt,
    DateTime? updatedAt,
    String? barcode,
    String? qrCode,
  }) => Meta(
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    barcode: barcode ?? this.barcode,
    qrCode: qrCode ?? this.qrCode,
  );

  factory Meta.fromMap(Map<String, dynamic> json) => Meta(
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    barcode: json["barcode"],
    qrCode: json["qrCode"],
  );

  Map<String, dynamic> toMap() => {
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "barcode": barcode,
    "qrCode": qrCode,
  };
}

class Review {
  final int? rating;
  final String? comment;
  final DateTime? date;
  final String? reviewerName;
  final String? reviewerEmail;

  Review({
    this.rating,
    this.comment,
    this.date,
    this.reviewerName,
    this.reviewerEmail,
  });

  Review copyWith({
    int? rating,
    String? comment,
    DateTime? date,
    String? reviewerName,
    String? reviewerEmail,
  }) => Review(
    rating: rating ?? this.rating,
    comment: comment ?? this.comment,
    date: date ?? this.date,
    reviewerName: reviewerName ?? this.reviewerName,
    reviewerEmail: reviewerEmail ?? this.reviewerEmail,
  );

  factory Review.fromMap(Map<String, dynamic> json) => Review(
    rating: json["rating"],
    comment: json["comment"],
    date: DateTime.parse(json["date"]),
    reviewerName: json["reviewerName"],
    reviewerEmail: json["reviewerEmail"],
  );

  Map<String, dynamic> toMap() => {
    "rating": rating,
    "comment": comment,
    "date": date?.toIso8601String(),
    "reviewerName": reviewerName,
    "reviewerEmail": reviewerEmail,
  };
}