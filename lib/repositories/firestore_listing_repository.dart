import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/campus_user.dart';
import '../models/listing.dart';
import 'listing_repository.dart';

class FirestoreListingRepository implements ListingRepository {
  FirestoreListingRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('listings');

  @override
  Stream<List<Listing>> watchListings() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Listing.fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  @override
  Future<void> addListing({
    required ListingDraft draft,
    required CampusUser owner,
  }) async {
    final now = DateTime.now();
    await _collection.add({
      ..._draftMap(draft),
      'ownerId': owner.id,
      'ownerName': owner.displayName,
      'contactEmail': owner.email,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  @override
  Future<void> updateListing({
    required String id,
    required ListingDraft draft,
  }) async {
    await _collection.doc(id).update({
      ..._draftMap(draft),
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<void> deleteListing(String id) {
    return _collection.doc(id).delete();
  }

  Map<String, dynamic> _draftMap(ListingDraft draft) {
    return {
      'title': draft.title,
      'description': draft.description,
      'category': draft.category,
      'condition': draft.condition,
      'price': draft.price,
      'location': draft.location?.toMap(),
      'imagePath': draft.imagePath,
    };
  }
}
