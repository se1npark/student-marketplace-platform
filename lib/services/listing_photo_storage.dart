import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../models/campus_user.dart';
import 'device_service.dart';

abstract class ListingPhotoStorage {
  Future<String> uploadListingPhoto({
    required PickedListingPhoto photo,
    required CampusUser owner,
  });
}

class FirebaseListingPhotoStorage implements ListingPhotoStorage {
  FirebaseListingPhotoStorage({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<String> uploadListingPhoto({
    required PickedListingPhoto photo,
    required CampusUser owner,
  }) async {
    final safeName = _safeFileName(photo.name);
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final ref = _storage.ref('listing_photos/${owner.id}/$timestamp-$safeName');

    await ref.putData(
      Uint8List.fromList(photo.bytes),
      SettableMetadata(contentType: photo.mimeType ?? _contentType(safeName)),
    );
    return ref.getDownloadURL();
  }
}

class MemoryListingPhotoStorage implements ListingPhotoStorage {
  @override
  Future<String> uploadListingPhoto({
    required PickedListingPhoto photo,
    required CampusUser owner,
  }) async {
    return photo.path;
  }
}

String _safeFileName(String name) {
  final sanitized = name.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
  return sanitized.isEmpty ? 'listing-photo.jpg' : sanitized;
}

String _contentType(String fileName) {
  final lower = fileName.toLowerCase();
  if (lower.endsWith('.png')) {
    return 'image/png';
  }
  if (lower.endsWith('.webp')) {
    return 'image/webp';
  }
  return 'image/jpeg';
}
