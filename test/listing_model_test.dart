import 'package:campus_cart/models/listing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('listing maps preserve price, dates, and nested location', () {
    final listing = Listing.fromMap('listing-1', {
      'title': 'USB-C charger',
      'description': 'Fast charger for laptop or phone.',
      'category': 'Electronics',
      'condition': 'Good',
      'price': '19.50',
      'ownerId': 'owner-1',
      'ownerName': 'Jordan Lee',
      'contactEmail': 'jordan@student.mq.edu.au',
      'createdAt': '2026-05-01T10:00:00.000',
      'updatedAt': '2026-05-02T10:00:00.000',
      'location': {
        'latitude': -33.7756,
        'longitude': 151.1126,
        'label': 'Central Courtyard',
      },
    });

    expect(listing.price, 19.5);
    expect(listing.location?.label, 'Central Courtyard');
    expect(listing.createdAt.year, 2026);

    final map = listing.toMap();

    expect(map['title'], 'USB-C charger');
    expect(map['location'], isA<Map<String, dynamic>>());
  });

  test('copyWith preserves unchanged fields', () {
    final original = Listing(
      id: 'test-1',
      title: 'Original title',
      description: 'Original description',
      category: 'Textbooks',
      condition: 'Good',
      price: 20,
      ownerId: 'owner-1',
      ownerName: 'Jordan Lee',
      contactEmail: 'jordan@student.mq.edu.au',
      createdAt: DateTime(2026, 5, 1),
      updatedAt: DateTime(2026, 5, 1),
      location: const ListingLocation(
        latitude: -33.7756,
        longitude: 151.1126,
        label: 'Library',
      ),
    );

    final updated = original.copyWith(title: 'Updated title', price: 25);

    expect(updated.title, 'Updated title');
    expect(updated.price, 25);
    expect(updated.id, original.id);
    expect(updated.description, original.description);
    expect(updated.ownerId, original.ownerId);
    expect(updated.location?.label, original.location?.label);
  });

  test('listing derives a readable owner name from student email fallback', () {
    final listing = Listing.fromMap('listing-2', {
      'title': 'USB Charger',
      'contactEmail': 'sein.park@students.mq.edu.au',
      'ownerName': 'Campus seller',
    });

    expect(listing.ownerName, 'Sein Park');
    expect(listing.contactEmail, 'sein.park@students.mq.edu.au');
  });
}
