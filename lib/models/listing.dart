const listingCategories = <String>[
  'Textbooks',
  'Food',
  'Electronics',
  'Services',
  'Other',
];

const listingConditions = <String>[
  'New',
  'Like new',
  'Good',
  'Fair',
  'Service',
];

class ListingLocation {
  const ListingLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;
  final String label;

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude, 'label': label};
  }

  factory ListingLocation.fromMap(Map<String, dynamic> map) {
    return ListingLocation(
      latitude: _readDouble(map['latitude']),
      longitude: _readDouble(map['longitude']),
      label: (map['label'] as String?) ?? 'Campus location',
    );
  }
}

class ListingDraft {
  const ListingDraft({
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.price,
    this.location,
    this.imagePath,
  });

  final String title;
  final String description;
  final String category;
  final String condition;
  final double price;
  final ListingLocation? location;
  final String? imagePath;
}

class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.condition,
    required this.price,
    required this.ownerId,
    required this.ownerName,
    required this.contactEmail,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.imagePath,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String condition;
  final double price;
  final String ownerId;
  final String ownerName;
  final String contactEmail;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ListingLocation? location;
  final String? imagePath;

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? condition,
    double? price,
    String? ownerId,
    String? ownerName,
    String? contactEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    ListingLocation? location,
    String? imagePath,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      price: price ?? this.price,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      contactEmail: contactEmail ?? this.contactEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  factory Listing.fromMap(String id, Map<String, dynamic> map) {
    final contactEmail = (map['contactEmail'] as String?) ?? '';
    return Listing(
      id: id,
      title: (map['title'] as String?) ?? 'Untitled listing',
      description: (map['description'] as String?) ?? '',
      category: (map['category'] as String?) ?? 'Other',
      condition: (map['condition'] as String?) ?? 'Good',
      price: _readDouble(map['price']),
      ownerId: (map['ownerId'] as String?) ?? '',
      ownerName: _readOwnerName(map['ownerName'] as String?, contactEmail),
      contactEmail: contactEmail,
      createdAt: _readDate(map['createdAt']),
      updatedAt: _readDate(map['updatedAt']),
      location: _readLocation(map['location']),
      imagePath: map['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'condition': condition,
      'price': price,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'contactEmail': contactEmail,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (location != null) 'location': location!.toMap(),
      if (imagePath != null && imagePath!.isNotEmpty) 'imagePath': imagePath,
    };
  }
}

String _readOwnerName(String? ownerName, String contactEmail) {
  final trimmedName = ownerName?.trim();
  if (trimmedName != null &&
      trimmedName.isNotEmpty &&
      trimmedName != 'Campus seller') {
    return trimmedName;
  }

  final localPart = contactEmail.split('@').first.trim();
  if (localPart.isEmpty) {
    return 'Campus seller';
  }

  return localPart
      .split(RegExp(r'[._-]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => part[0].toUpperCase() + part.substring(1))
      .join(' ');
}

ListingLocation? _readLocation(Object? value) {
  if (value is Map<String, dynamic>) {
    return ListingLocation.fromMap(value);
  }

  if (value is Map) {
    return ListingLocation.fromMap(Map<String, dynamic>.from(value));
  }

  return null;
}

double _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }

  if (value is String) {
    return double.tryParse(value) ?? 0;
  }

  return 0;
}

DateTime _readDate(Object? value) {
  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  try {
    final date = (value as dynamic).toDate();
    if (date is DateTime) {
      return date;
    }
  } catch (_) {
    // Firestore timestamps expose toDate; demo data may not.
  }

  return DateTime.now();
}
