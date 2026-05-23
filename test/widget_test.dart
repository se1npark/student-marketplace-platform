import 'package:campus_cart/app.dart';
import 'package:campus_cart/bootstrap.dart';
import 'package:campus_cart/models/listing.dart';
import 'package:campus_cart/repositories/memory_auth_repository.dart';
import 'package:campus_cart/repositories/memory_listing_repository.dart';
import 'package:campus_cart/services/device_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('auth form validates email and password before sign in', (
    tester,
  ) async {
    _setIphoneViewport(tester);
    final dependencies = AppDependencies(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository(),
      deviceService: _FakeDeviceService(),
      usingDemoBackend: true,
    );

    await tester.pumpWidget(CampusCartApp(dependencies: dependencies));
    await tester.pump();

    await tester.tap(find.byKey(const Key('authSubmitButton')));
    await tester.pump();

    expect(find.text('Enter a valid email.'), findsOneWidget);
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
  });

  testWidgets('student can sign in and create a listing', (tester) async {
    _setIphoneViewport(tester);
    final dependencies = AppDependencies(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository(),
      deviceService: _FakeDeviceService(),
      usingDemoBackend: true,
    );

    await tester.pumpWidget(CampusCartApp(dependencies: dependencies));
    await tester.pump();

    await _useDemoLogin(tester);

    expect(find.text('No listings match'), findsOneWidget);

    await tester.tap(find.byKey(const Key('addListingButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('listingTitleField')),
      'Graphing calculator',
    );
    await tester.enterText(
      find.byKey(const Key('listingDescriptionField')),
      'Casio calculator for statistics units.',
    );
    await tester.enterText(find.byKey(const Key('listingPriceField')), '35');

    await _scrollUntilVisible(tester, const Key('captureLocationButton'));
    await tester.tap(find.byKey(const Key('captureLocationButton')));
    await tester.pumpAndSettle();

    expect(find.text('Library lawn'), findsOneWidget);

    await _scrollUntilVisible(tester, const Key('saveListingButton'));
    await tester.tap(find.byKey(const Key('saveListingButton')));
    await tester.pumpAndSettle();

    expect(find.text('Graphing calculator'), findsOneWidget);
    expect(find.text('Casio calculator for statistics units.'), findsOneWidget);
    expect(find.text('Library lawn'), findsOneWidget);
  });

  testWidgets('student can edit and delete their own listing', (tester) async {
    _setIphoneViewport(tester);
    final dependencies = AppDependencies(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository.withSeedData(),
      deviceService: _FakeDeviceService(),
      usingDemoBackend: true,
    );

    await tester.pumpWidget(CampusCartApp(dependencies: dependencies));
    await tester.pump();

    await _useDemoLogin(tester);

    await tester.enterText(find.byKey(const Key('listingSearchField')), 'cup');
    await tester.pumpAndSettle();

    expect(find.text('Reusable cup for The Hub'), findsOneWidget);

    await _openListingActions(tester, 'Reusable cup for The Hub');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('listingTitleField')),
      'Reusable cup and lid for The Hub',
    );
    await _scrollUntilVisible(tester, const Key('saveListingButton'));
    await tester.tap(find.byKey(const Key('saveListingButton')));
    await tester.pumpAndSettle();

    expect(find.text('Reusable cup and lid for The Hub'), findsOneWidget);
    expect(find.text('Reusable cup for The Hub'), findsNothing);

    await _openListingActions(tester, 'Reusable cup and lid for The Hub');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Reusable cup and lid for The Hub'), findsNothing);
  });

  testWidgets('student can search, open details, and save a listing', (
    tester,
  ) async {
    _setIphoneViewport(tester);
    final dependencies = AppDependencies(
      authRepository: MemoryAuthRepository.withDemoUser(),
      listingRepository: MemoryListingRepository.withSeedData(),
      deviceService: _FakeDeviceService(),
      usingDemoBackend: true,
    );

    await tester.pumpWidget(CampusCartApp(dependencies: dependencies));
    await tester.pump();

    await _useDemoLogin(tester);

    await tester.enterText(
      find.byKey(const Key('listingSearchField')),
      'charger',
    );
    await tester.pumpAndSettle();

    expect(find.text('USB-C charger for Library study'), findsOneWidget);
    expect(find.text('Reusable cup for The Hub'), findsNothing);

    await tester.tap(find.text('USB-C charger for Library study'));
    await tester.pumpAndSettle();

    expect(find.text('Listing details'), findsOneWidget);
    expect(find.text('Pickup point'), findsOneWidget);

    await tester.tap(find.byTooltip('Save listing'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Unsave listing'), findsOneWidget);
  });
}

void _setIphoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _useDemoLogin(WidgetTester tester) async {
  final button = find.byKey(const Key('useDemoLoginButton'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

Future<void> _scrollUntilVisible(WidgetTester tester, Key key) async {
  final target = find.byKey(key);
  for (var i = 0; i < 8 && tester.any(target) == false; i += 1) {
    await tester.drag(find.byType(ListView).last, const Offset(0, -280));
    await tester.pumpAndSettle();
  }
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Future<void> _openListingActions(
  WidgetTester tester,
  String listingTitle,
) async {
  final card = find.ancestor(
    of: find.text(listingTitle),
    matching: find.byType(Card),
  );
  final menuButton = find.descendant(
    of: card,
    matching: find.byTooltip('Listing actions'),
  );

  expect(menuButton, findsOneWidget);
  await tester.tap(menuButton);
  await tester.pumpAndSettle();
}

class _FakeDeviceService implements DeviceService {
  @override
  Future<ListingLocation> currentLocation() async {
    return const ListingLocation(
      latitude: -33.7756,
      longitude: 151.1126,
      label: 'Library lawn',
    );
  }

  @override
  Future<String?> pickListingPhoto() async => '/tmp/calculator.png';
}
