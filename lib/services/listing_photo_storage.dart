import 'dart:convert';
import 'dart:typed_data';

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

// Unsigned upload preset lets the client post directly to Cloudinary without
// exposing an API secret. The returned secure_url is an HTTPS CDN link that
// works on every platform without CORS or Firebase Storage bucket setup.
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
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          Uint8List.fromList(photo.bytes),
          filename: photo.name,
        ),
      );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      final error =
          (jsonDecode(body) as Map<String, dynamic>)['error']?['message']
              as String? ??
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
