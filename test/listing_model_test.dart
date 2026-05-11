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
}
