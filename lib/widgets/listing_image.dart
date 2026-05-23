import 'package:flutter/material.dart';

import 'listing_file_image.dart';

class ListingImage extends StatelessWidget {
  const ListingImage({
    super.key,
    required this.imagePath,
    required this.fallbackIcon,
    this.fit = BoxFit.cover,
  });

  final String? imagePath;
  final IconData fallbackIcon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final theme = Theme.of(context);
    final fallback = Icon(
      fallbackIcon,
      color: theme.colorScheme.onPrimaryContainer,
    );

    if (path == null || path.isEmpty) {
      return fallback;
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    final uri = Uri.tryParse(path);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => fallback,
      );
    }

    return buildListingFileImage(path, fit, fallback);
  }
}
