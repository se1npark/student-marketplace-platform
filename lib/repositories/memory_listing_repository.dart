import 'dart:async';

import 'package:uuid/uuid.dart';

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
          description: 'Printed lecture notes and revision cards.',
          category: 'Textbooks',
          condition: 'Good',
          price: 18,
          ownerId: 'demo-user-alex',
          ownerName: 'Alex Chen',
          contactEmail: 'alex@student.mq.edu.au',
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now.subtract(const Duration(days: 2)),
          location: const ListingLocation(
            latitude: -33.7756,
            longitude: 151.1126,
            label: 'Central Courtyard',
          ),
        ),
        Listing(
          id: 'seed-coffee',
          title: 'Reusable coffee cup',
          description: 'Insulated cup, clean and barely used.',
          category: 'Food',
          condition: 'Like new',
          price: 9,
          ownerId: 'demo-user-alex',
          ownerName: 'Alex Chen',
          contactEmail: 'alex@student.mq.edu.au',
          createdAt: now.subtract(const Duration(hours: 9)),
          updatedAt: now.subtract(const Duration(hours: 9)),
        ),
        Listing(
          id: 'seed-service',
          title: '30 min app testing swap',
          description: 'I test your app, you test mine before demo week.',
          category: 'Services',
          condition: 'Service',
          price: 0,
          ownerId: 'demo-user-alex',
          ownerName: 'Alex Chen',
          contactEmail: 'alex@student.mq.edu.au',
          createdAt: now.subtract(const Duration(hours: 3)),
          updatedAt: now.subtract(const Duration(hours: 3)),
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
