import 'dart:async';

import 'package:uuid/uuid.dart';

import '../campus_content.dart';
import '../models/campus_user.dart';
import '../models/listing.dart';
import 'listing_repository.dart';

class MemoryListingRepository implements ListingRepository {
  MemoryListingRepository({List<Listing> seedListings = const []})
    : _listings = [...seedListings] {
    _sort();
  }

  factory MemoryListingRepository.withSeedData() {
    final now = DateTime.now();
    return MemoryListingRepository(
      seedListings: [
        Listing(
          id: 'seed-textbook',
          title: 'COMP3130 Android notes pack',
          description:
              'Printed Mobile App Development notes, revision cards and Firebase setup checklist. Pickup near 1 Central Courtyard.',
          category: 'Textbooks',
          condition: 'Good',
          price: 18,
          ownerId: 'demo-user-sein',
          ownerName: 'Sein Park',
          contactEmail: 'sein.park@student.mq.edu.au',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
          location: const ListingLocation(
            latitude: -33.7756,
            longitude: 151.1126,
            label: '1 Central Courtyard',
          ),
        ),
        Listing(
          id: 'seed-coffee',
          title: 'Reusable cup for The Hub',
          description:
              'Insulated cup for coffee runs around the Central Courtyard food outlets. Clean, barely used, easy handover after class.',
          category: 'Food',
          condition: 'Like new',
          price: 9,
          ownerId: 'demo-user-sein',
          ownerName: 'Sein Park',
          contactEmail: 'sein.park@student.mq.edu.au',
          createdAt: now.subtract(const Duration(hours: 9)),
          updatedAt: now.subtract(const Duration(hours: 9)),
          location: const ListingLocation(
            latitude: -33.7756,
            longitude: 151.1126,
            label: 'The Hub at 1CC',
          ),
          imagePath: CampusContent.campusHeroImageAsset,
        ),
        Listing(
          id: 'seed-charger',
          title: 'USB-C charger for Library study',
          description:
              '65W USB-C charger that suits most laptops and tablets. Handy backup for long study days near the MQ Library.',
          category: 'Electronics',
          condition: 'Good',
          price: 22,
          ownerId: 'demo-user-sein',
          ownerName: 'Sein Park',
          contactEmail: 'sein.park@student.mq.edu.au',
          createdAt: now.subtract(const Duration(hours: 15)),
          updatedAt: now.subtract(const Duration(hours: 15)),
          location: const ListingLocation(
            latitude: -33.7756,
            longitude: 151.1126,
            label: 'MQ Library',
          ),
        ),
        Listing(
          id: 'seed-service',
          title: '30 min app testing swap',
          description:
              'Peer QA session before demo week: I test your app, you test mine. Meet on campus with two devices if needed.',
          category: 'Services',
          condition: 'Service',
          price: 0,
          ownerId: 'demo-user-sein',
          ownerName: 'Sein Park',
          contactEmail: 'sein.park@student.mq.edu.au',
          createdAt: now.subtract(const Duration(hours: 3)),
          updatedAt: now.subtract(const Duration(hours: 3)),
          location: const ListingLocation(
            latitude: -33.7756,
            longitude: 151.1126,
            label: 'Library study area',
          ),
        ),
        Listing(
          id: 'seed-umbrella',
          title: 'MQ umbrella',
          description:
              'Compact red umbrella for rainy walks between the Metro station, Central Courtyard and class.',
          category: 'Other',
          condition: 'Fair',
          price: 6,
          ownerId: 'demo-user-sein',
          ownerName: 'Sein Park',
          contactEmail: 'sein.park@student.mq.edu.au',
          createdAt: now.subtract(const Duration(hours: 30)),
          updatedAt: now.subtract(const Duration(hours: 30)),
          location: const ListingLocation(
            latitude: -33.7756,
            longitude: 151.1126,
            label: 'Metro side entrance',
          ),
        ),
      ],
    );
  }

  final List<Listing> _listings;
  final StreamController<List<Listing>> _controller =
      StreamController<List<Listing>>.broadcast();

  @override
  Stream<List<Listing>> watchListings() async* {
    yield List.unmodifiable(_listings);
    yield* _controller.stream;
  }

  @override
  Future<void> addListing({
    required ListingDraft draft,
    required CampusUser owner,
  }) async {
    final now = DateTime.now();
    _listings.add(
      Listing(
        id: const Uuid().v4(),
        title: draft.title,
        description: draft.description,
        category: draft.category,
        condition: draft.condition,
        price: draft.price,
        ownerId: owner.id,
        ownerName: owner.displayName,
        contactEmail: owner.email,
        createdAt: now,
        updatedAt: now,
        location: draft.location,
        imagePath: draft.imagePath,
      ),
    );
    _publish();
  }

  @override
  Future<void> updateListing({
    required String id,
    required ListingDraft draft,
  }) async {
    final index = _listings.indexWhere((listing) => listing.id == id);
    if (index == -1) {
      throw const ListingException('Listing was not found.');
    }

    _listings[index] = _listings[index].copyWith(
      title: draft.title,
      description: draft.description,
      category: draft.category,
      condition: draft.condition,
      price: draft.price,
      updatedAt: DateTime.now(),
      location: draft.location,
      imagePath: draft.imagePath,
    );
    _publish();
  }

  @override
  Future<void> deleteListing(String id) async {
    _listings.removeWhere((listing) => listing.id == id);
    _publish();
  }

  void _publish() {
    _sort();
    _controller.add(List.unmodifiable(_listings));
  }

  void _sort() {
    _listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void dispose() {
    _controller.close();
  }
}
