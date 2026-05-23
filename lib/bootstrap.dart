import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'repositories/auth_repository.dart';
import 'repositories/firebase_auth_repository.dart';
import 'repositories/firestore_listing_repository.dart';
import 'repositories/listing_repository.dart';
import 'repositories/memory_auth_repository.dart';
import 'repositories/memory_listing_repository.dart';
import 'services/device_service.dart';
import 'services/listing_photo_storage.dart';

class AppDependencies {
  const AppDependencies({
    required this.authRepository,
    required this.listingRepository,
    required this.deviceService,
    required this.photoStorage,
    required this.usingDemoBackend,
    this.startupNotice,
  });

  final AuthRepository authRepository;
  final ListingRepository listingRepository;
  final DeviceService deviceService;
  final ListingPhotoStorage photoStorage;
  final bool usingDemoBackend;
  final String? startupNotice;
}

Future<AppDependencies> buildDependencies() async {
  const forceDemoBackend = bool.fromEnvironment('DEMO_BACKEND');
  final deviceService = DeviceServiceImpl();

  if (forceDemoBackend) {
    return AppDependencies(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository.withSeedData(),
      deviceService: deviceService,
      photoStorage: MemoryListingPhotoStorage(),
      usingDemoBackend: true,
      startupNotice: 'Demo backend selected with DEMO_BACKEND.',
    );
  }

  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (!_looksConfigured(options)) {
      return AppDependencies(
        authRepository: MemoryAuthRepository.withDemoUser(),
        listingRepository: MemoryListingRepository.withSeedData(),
        deviceService: deviceService,
        photoStorage: MemoryListingPhotoStorage(),
        usingDemoBackend: true,
        startupNotice: 'Firebase options are placeholders.',
      );
    }

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    }

    return AppDependencies(
      authRepository: FirebaseAuthRepository(),
      listingRepository: FirestoreListingRepository(),
      deviceService: deviceService,
      photoStorage: FirebaseListingPhotoStorage(),
      usingDemoBackend: false,
    );
  } catch (error) {
    return AppDependencies(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository.withSeedData(),
      deviceService: deviceService,
      photoStorage: MemoryListingPhotoStorage(),
      usingDemoBackend: true,
      startupNotice: 'Firebase could not start: $error',
    );
  }
}

bool _looksConfigured(FirebaseOptions options) {
  final requiredValues = <String>[
    options.apiKey,
    options.appId,
    options.messagingSenderId,
    options.projectId,
  ];

  return requiredValues.every(
    (value) =>
        value.trim().isNotEmpty &&
        !value.contains('REPLACE_WITH') &&
        !value.contains('campus-cart-placeholder'),
  );
}
