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
      _listingsLoaded = true;
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
  final Set<String> _savedListingIds = <String>{};
  bool _busy = false;
  bool _listingsLoaded = false;
  String? _errorMessage;
  String _categoryFilter = 'All';
  String _searchQuery = '';

  CampusUser? get user => _user;
  bool get isBusy => _busy;
  bool get isLoadingListings => !_listingsLoaded;
  String? get errorMessage => _errorMessage;
  String get categoryFilter => _categoryFilter;
  String get searchQuery => _searchQuery;
  int get totalListingCount => _listings.length;
  int get savedListingCount => _savedListingIds.length;
  int get ownListingCount =>
      _listings.where((listing) => listing.ownerId == _user?.id).length;

  List<String> get filterOptions => const ['All', ...listingCategories];

  List<Listing> get listings => _filtered(_listings);

  List<Listing> get savedListings => _filtered(
    _listings
        .where((listing) => _savedListingIds.contains(listing.id))
        .toList(growable: false),
  );

  List<Listing> get myListings => _filtered(
    _listings
        .where((listing) => listing.ownerId == _user?.id)
        .toList(growable: false),
  );

  void setCategoryFilter(String category) {
    _categoryFilter = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    notifyListeners();
  }

  void toggleSaved(String listingId) {
    if (_savedListingIds.contains(listingId)) {
      _savedListingIds.remove(listingId);
    } else {
      _savedListingIds.add(listingId);
    }
    notifyListeners();
  }

  bool isSaved(String listingId) => _savedListingIds.contains(listingId);

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

  Future<bool> resetPassword(String email) {
    return _run(() => _authRepository.resetPassword(email));
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

  List<Listing> _filtered(List<Listing> source) {
    final byCategory = _categoryFilter == 'All'
        ? source
        : source
              .where((listing) => listing.category == _categoryFilter)
              .toList(growable: false);

    if (_searchQuery.isEmpty) {
      return byCategory;
    }

    return byCategory
        .where((listing) {
          final text =
              '${listing.title} ${listing.description} ${listing.category} ${listing.location?.label ?? ''}'
                  .toLowerCase();
          return text.contains(_searchQuery);
        })
        .toList(growable: false);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _listingSubscription?.cancel();
    super.dispose();
  }
}
