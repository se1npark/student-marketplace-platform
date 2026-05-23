import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../models/listing.dart';

abstract class DeviceService {
  Future<ListingLocation> currentLocation();

  Future<PickedListingPhoto?> pickListingPhoto();
}

class DeviceServiceImpl implements DeviceService {
  DeviceServiceImpl({GeolocatorPlatform? geolocator, ImagePicker? imagePicker})
    : _geolocator = geolocator ?? GeolocatorPlatform.instance,
      _imagePicker = imagePicker ?? ImagePicker();

  final GeolocatorPlatform _geolocator;
  final ImagePicker _imagePicker;

  @override
  Future<ListingLocation> currentLocation() async {
    final serviceEnabled = await _geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const DeviceException('Location services are switched off.');
    }

    var permission = await _geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const DeviceException('Location permission was not granted.');
    }

    final position = await _geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return ListingLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      label: 'Pinned from current location',
    );
  }

  @override
  Future<PickedListingPhoto?> pickListingPhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 82,
    );
    if (image == null) {
      return null;
    }

    return PickedListingPhoto(
      path: image.path,
      name: image.name,
      mimeType: image.mimeType,
      bytes: await image.readAsBytes(),
    );
  }
}

class PickedListingPhoto {
  const PickedListingPhoto({
    required this.path,
    required this.name,
    required this.bytes,
    this.mimeType,
  });

  final String path;
  final String name;
  final List<int> bytes;
  final String? mimeType;
}

class DeviceException implements Exception {
  const DeviceException(this.message);

  final String message;

  @override
  String toString() => message;
}
