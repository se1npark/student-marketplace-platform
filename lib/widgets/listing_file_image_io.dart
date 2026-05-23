import 'dart:io';

import 'package:flutter/material.dart';

Widget buildListingFileImage(String path, BoxFit fit, Widget fallback) {
  final file = File(path);
  if (!file.existsSync()) {
    return fallback;
  }

  return Image.file(
    file,
    fit: fit,
    errorBuilder: (context, error, stackTrace) => fallback,
  );
}
