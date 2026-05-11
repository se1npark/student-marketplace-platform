import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/campus_user.dart';
import '../models/listing.dart';
import '../repositories/auth_repository.dart';
import '../repositories/listing_repository.dart';
import '../services/device_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required AuthRepository authRepository,
    required ListingRepository listingRepository,
    required DeviceService deviceService,
    required this.usingDemoBackend,
    this.startupNotice,
  }) : _authRepository = authRepository,
       _listingRepository = listingRepository,
       _deviceService = deviceService {
    _authSubscription = _authRepository.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    }, onError: _setError);

    _listingSubscription = _listingRepository.watchListings().listen((
      listings,
    ) {
      _listings = listings;
      notifyListeners();
    }, onError: _setError);
  }

  final AuthRepository _authRepository;
  final ListingRepository _listingRepository;
  final DeviceService _deviceService;
  final bool usingDemoBackend;
  final String? startupNotice;

  StreamSubscription<CampusUser?>? _authSubscription;
  StreamSubscription<List<Listing>>? _listingSubscription;

  CampusUser? _user;
  List<Listing> _listings = const [];
  bool _busy = false;
  String? _errorMessage;
  String _categoryFilter = 'All';

  CampusUser? get user => _user;
  bool get isBusy => _busy;
  String? get errorMessage => _errorMessage;
  String get categoryFilter => _categoryFilter;

  List<String> get filterOptions => const ['All', ...listingCategories];

  List<Listing> get listings {
    if (_categoryFilter == 'All') {
      return _listings;
    }

    return _listings
        .where((listing) => listing.category == _categoryFilter)
        .toList(growable: false);
  }

  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) {
    return _run(() => _authRepository.signIn(email: email, password: password));
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => _authRepository.register(
        name: name,
        email: email,
        password: password,
      ),
    );
  }

  Future<bool> signOut() {
    return _run(_authRepository.signOut);
  }

  Future<bool> createListing(ListingDraft draft) {
    final owner = _user;
    if (owner == null) {
      _setError(const ListingException('Please sign in again.'));
      return Future.value(false);
    }

    return _run(
      () => _listingRepository.addListing(draft: draft, owner: owner),
    );
  }

  Future<bool> updateListing(String id, ListingDraft draft) {
    return _run(() => _listingRepository.updateListing(id: id, draft: draft));
  }

  Future<bool> deleteListing(String id) {
    return _run(() => _listingRepository.deleteListing(id));
  }

  Future<ListingLocation?> captureLocation() async {
    final result = await _runValue(_deviceService.currentLocation);
    return result;
  }

  Future<String?> pickPhotoPath() {
    return _runValue<String?>(_deviceService.pickListingPhoto);
  }

  Future<bool> _run(Future<void> Function() action) async {
    final result = await _runValue(() async {
      await action();
      return true;
    });
    return result ?? false;
  }

  Future<T?> _runValue<T>(Future<T> Function() action) async {
    _busy = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await action();
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _setError(Object error) {
    if (error is AuthException ||
        error is ListingException ||
        error is DeviceException) {
      _errorMessage = error.toString();
    } else {
      _errorMessage = 'Something went wrong: $error';
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _listingSubscription?.cancel();
    super.dispose();
  }
}
