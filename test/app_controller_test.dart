import 'package:campus_cart/controllers/app_controller.dart';
import 'package:campus_cart/models/listing.dart';
import 'package:campus_cart/repositories/memory_auth_repository.dart';
import 'package:campus_cart/repositories/memory_listing_repository.dart';
import 'package:campus_cart/services/device_service.dart';
import 'package:campus_cart/services/listing_photo_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('filters listings by category', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository.withSeedData(),
      deviceService: _FakeDeviceService(),
      photoStorage: MemoryListingPhotoStorage(),
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
      photoStorage: MemoryListingPhotoStorage(),
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
      photoStorage: MemoryListingPhotoStorage(),
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
        photoStorage: MemoryListingPhotoStorage(),
        usingDemoBackend: true,
      );
      await pumpEventQueue();

      await controller.signIn(
        email: 'sein.park@students.mq.edu.au',
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
      photoStorage: MemoryListingPhotoStorage(),
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

  test('createListing adds a listing owned by the signed-in user', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository(),
      deviceService: _FakeDeviceService(),
      photoStorage: MemoryListingPhotoStorage(),
      usingDemoBackend: true,
    );

    await controller.signIn(
      email: 'sein.park@students.mq.edu.au',
      password: 'CampusCart1!',
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
    await pumpEventQueue();

    expect(success, isTrue);
    expect(controller.listings, hasLength(1));
    expect(controller.listings.single.title, 'Desk lamp');
    expect(controller.listings.single.ownerId, 'demo-user-sein');
    controller.dispose();
  });

  test('deleteListing removes the listing from the feed', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository.withSeedData(),
      deviceService: _FakeDeviceService(),
      photoStorage: MemoryListingPhotoStorage(),
      usingDemoBackend: true,
    );
    await pumpEventQueue();

    expect(controller.listings, hasLength(5));

    final success = await controller.deleteListing('seed-textbook');
    await pumpEventQueue();

    expect(success, isTrue);
    expect(controller.listings, hasLength(4));
    expect(
      controller.listings.any((l) => l.id == 'seed-textbook'),
      isFalse,
    );
    controller.dispose();
  });

  test('clearError dismisses the current error message', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository(),
      deviceService: _FakeDeviceService(),
      photoStorage: MemoryListingPhotoStorage(),
      usingDemoBackend: true,
    );

    await controller.signIn(
      email: 'sein.park@students.mq.edu.au',
      password: 'wrongpassword',
    );

    expect(controller.errorMessage, isNotNull);

    controller.clearError();

    expect(controller.errorMessage, isNull);
    controller.dispose();
  });

  test('sign out clears the current user', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository(),
      deviceService: _FakeDeviceService(),
      photoStorage: MemoryListingPhotoStorage(),
      usingDemoBackend: true,
    );

    await controller.signIn(
      email: 'sein.park@students.mq.edu.au',
      password: 'CampusCart1!',
    );
    await pumpEventQueue();

    expect(controller.user, isNotNull);

    await controller.signOut();
    await pumpEventQueue();

    expect(controller.user, isNull);
    controller.dispose();
  });

  test('failed sign in surfaces an error message', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository(),
      deviceService: _FakeDeviceService(),
      photoStorage: MemoryListingPhotoStorage(),
      usingDemoBackend: true,
    );

    final success = await controller.signIn(
      email: 'sein.park@students.mq.edu.au',
      password: 'wrongpassword',
    );

    expect(success, isFalse);
    expect(controller.errorMessage, isNotNull);
    expect(controller.errorMessage, contains('incorrect'));
    controller.dispose();
  });

  test('captures location and photo path through the device service', () async {
    final controller = AppController(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository(),
      deviceService: _FakeDeviceService(),
      photoStorage: MemoryListingPhotoStorage(),
      usingDemoBackend: true,
    );

    final location = await controller.captureLocation();
    final photo = await controller.pickListingPhoto();

    expect(location?.label, 'Library lawn');
    expect(photo?.path, '/tmp/calculator.png');
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
  Future<PickedListingPhoto?> pickListingPhoto() async {
    return const PickedListingPhoto(
      path: '/tmp/calculator.png',
      name: 'calculator.png',
      bytes: <int>[1, 2, 3],
      mimeType: 'image/png',
    );
  }
}
