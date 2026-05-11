import '../models/campus_user.dart';
import '../models/listing.dart';

abstract class ListingRepository {
  Stream<List<Listing>> watchListings();

  Future<void> addListing({
    required ListingDraft draft,
    required CampusUser owner,
  });

  Future<void> updateListing({required String id, required ListingDraft draft});

  Future<void> deleteListing(String id);
}

class ListingException implements Exception {
  const ListingException(this.message);

  final String message;

  @override
  String toString() => message;
}
