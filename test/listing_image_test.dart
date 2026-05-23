import 'dart:convert';
import 'dart:io';

import 'package:campus_cart/widgets/listing_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('listing image renders local picker file paths', (tester) async {
    final tempDir = Directory.systemTemp.createTempSync('campus-cart-image-');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final imageFile = File('${tempDir.path}/listing.png');
    imageFile.writeAsBytesSync(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAFgwJ/lIu5aAAAAABJRU5ErkJggg==',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ListingImage(
          imagePath: imageFile.path,
          fallbackIcon: Icons.local_offer,
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.local_offer), findsNothing);
  });
}
