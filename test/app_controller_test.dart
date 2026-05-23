import 'package:campus_cart/controllers/app_controller.dart';
import 'package:campus_cart/models/listing.dart';
import 'package:campus_cart/repositories/memory_auth_repository.dart';
import 'package:campus_cart/repositories/memory_listing_repository.dart';
import 'package:campus_cart/services/device_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters listings by category', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository.withSeedData(),
      deviceService: _FakeDeviceService(),
      usingDemoBackend: true,
    );
    await pumpEventQueue();

    expect(controller.listings, hasLength(5));

    controller.setCategoryFilter('Services');

    expect(controller.listings, hasLength(1));
    expect(controller.listings.single.category, 'Services');
    controller.dispose();
  });

  test('seed listings include every marketplace category', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository.withSeedData(),
      deviceService: _FakeDeviceService(),
      usingDemoBackend: true,
    );
    await pumpEventQueue();

    final seededCategories = controller.listings
        .map((listing) => listing.category)
        .toSet();

    expect(
      seededCategories,
      containsAll(['Textbooks', 'Food', 'Electronics', 'Services', 'Other']),
    );
    controller.dispose();
  });

  test('search query filters listing text and campus pickup labels', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository.withSeedData(),
      deviceService: _FakeDeviceService(),
      usingDemoBackend: true,
    );
    await pumpEventQueue();

    controller.setSearchQuery('library');

    expect(
      controller.listings.map((listing) => listing.id),
      containsAll(['seed-charger', 'seed-service']),
    );
    expect(controller.listings, hasLength(2));

    controller.setCategoryFilter('Electronics');

    expect(controller.listings.single.id, 'seed-charger');
    controller.dispose();
  });

  test(
    'saved and own listing collections update from controller state',
    () async {
      final controller = AppController(
        authRepository: MemoryAuthRepository.withDemoUser(),
        listingRepository: MemoryListingRepository.withSeedData(),
        deviceService: _FakeDeviceService(),
        usingDemoBackend: true,
      );
      await pumpEventQueue();

      await controller.signIn(
        email: 'sein.park@student.mq.edu.au',
        password: 'CampusCart1!',
      );
      await pumpEventQueue();

      controller.toggleSaved('seed-charger');

      expect(controller.savedListingCount, 1);
      expect(controller.savedListings.single.title, contains('USB-C charger'));
      expect(controller.myListings, hasLength(5));

      controller.toggleSaved('seed-charger');

      expect(controller.savedListings, isEmpty);
      controller.dispose();
    },
  );

  test('requires a signed-in user before creating a listing', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository(),
      deviceService: _FakeDeviceService(),
      usingDemoBackend: true,
    );
    await pumpEventQueue();

    const draft = ListingDraft(
      title: 'Desk lamp',
      description: 'Small lamp for late study.',
      category: 'Other',
      condition: 'Good',
      price: 8,
    );

    final success = await controller.createListing(draft);

    expect(success, isFalse);
    expect(controller.errorMessage, 'Please sign in again.');
    controller.dispose();
  });

  test('captures location and photo path through the device service', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository(),
      deviceService: _FakeDeviceService(),
      usingDemoBackend: true,
    );

    final location = await controller.captureLocation();
    final photoPath = await controller.pickPhotoPath();

    expect(location?.label, 'Library lawn');
    expect(photoPath, '/tmp/calculator.png');
    controller.dispose();
  });
}

class _FakeDeviceService implements DeviceService {
  @override
  Future<ListingLocation> currentLocation() async {
    return const ListingLocation(
      latitude: -33.7756,
      longitude: 151.1126,
      label: 'Library lawn',
    );
  }

  @override
  Future<String?> pickListingPhoto() async => '/tmp/calculator.png';
}
