import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

import '../models/campus_user.dart';
import '../repositories/listing_repository.dart';
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

class CloudinaryListingPhotoStorage implements ListingPhotoStorage {
  static const _cloudName = 'dmeakmx3m';
  static const _uploadPreset = 'pbwwndp3';

  @override
  Future<String> uploadListingPhoto({
    required PickedListingPhoto photo,
    required CampusUser owner,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        Uint8List.fromList(photo.bytes),
        filename: photo.name,
      ));

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      final error = (jsonDecode(body) as Map<String, dynamic>)['error']
              ?['message'] as String? ??
          'Upload failed (${streamed.statusCode})';
      throw ListingException(error);
    }

    return (jsonDecode(body) as Map<String, dynamic>)['secure_url'] as String;
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
