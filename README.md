# Campus Cart

**Tagline:** Buy, sell, and swap useful things around Macquarie's Wallumattagal Campus.

Campus Cart is a Flutter marketplace app for students who want a safer, smaller alternative to large public resale sites. The app focuses on everyday Macquarie exchanges: COMP3130 notes near 1 Central Courtyard, food and coffee items around The Hub, chargers and study equipment near the Library, and student-to-student services such as app testing swaps. A student can sign in, browse current listings, filter by category, create their own listing, attach a campus location, optionally attach a photo path, edit the listing later, and delete it when it is sold.

The app has been designed as a simple major project demonstration rather than a full commercial product. Its main data entity is a `Listing`, stored through a repository layer that supports create, read, update, and delete operations. Firebase Authentication and Cloud Firestore implementations are included, with an in-memory demo backend used automatically while Firebase options still contain placeholders. This keeps the app runnable for development and testing while making the intended remote backend clear in the code.

## Main Features

- Email/password authentication with Firebase-ready and demo implementations.
- Marketplace feed that reads listings from the listing repository in real time.
- Category filters for Textbooks, Food, Electronics, Services, and Other.
- Create, edit, and delete listing flows.
- Listing fields for title, description, category, condition, price, seller, contact email, optional image path, and optional location.
- Mobile device service integration through current device location using `geolocator`.
- Optional photo selection using `image_picker`.
- Unit and widget tests that run with `flutter test`.
- MQ-specific seed listings, campus pickup labels, and a marketplace header image sourced from the Macquarie University About page.

## Users

The primary users are Macquarie students who need quick, local exchanges with people already on campus. A first persona is Alex, a second-year computing student who buys used textbooks and sells old electronics after each session. Alex prefers Campus Cart over Facebook Marketplace because listings are scoped to campus and include student contact details. A second persona is Priya, a first-year student who wants affordable study items and uses the category filters to avoid scrolling through unrelated products. A third persona is Jordan, a student building a mobile app who offers peer testing sessions before assessment demos.

These users choose Campus Cart because it is lightweight and task-focused. They do not need auctions, shipping, public profiles, or complex payments. The app supports the practical campus handover: find an item, check the price and condition, see where the seller can meet, and contact them through their student email.

The campus context is based on Macquarie's official pages: the main campus is known as the Wallumattagal Campus, and MQ highlights campus green spaces, lifestyle facilities and food outlets. The app also references 1 Central Courtyard and The Hub because official MQ pages describe Central Courtyard as a major social, food and learning precinct.

## Technical Details

This project is built with Flutter and Dart. The current codebase uses a small layered structure:

- `lib/models`: `CampusUser`, `Listing`, `ListingDraft`, and `ListingLocation`.
- `lib/repositories`: abstract repositories plus Firebase and memory implementations.
- `lib/services`: device integrations for location and image picking.
- `lib/controllers`: `AppController`, the app state class used by the screens.
- `lib/screens`: authentication, marketplace, and listing form screens.
- `test`: repository and widget tests.

The production backend path is:

- `FirebaseAuthRepository` for sign in, registration, and sign out.
- `FirestoreListingRepository` for listing CRUD in the `listings` collection.

The app checks `lib/firebase_options.dart` at startup. If the values still contain placeholders, it starts in demo mode. To use Firebase for marking, replace the placeholder Firebase options with real Android, iOS, and web values from a Firebase project, enable Email/Password authentication, and create suitable Firestore rules for the `listings` collection.

## Test User

Demo mode login:

- Email: `sein.park@student.mq.edu.au`
- Password: `CampusCart1!`

For the final Firebase-backed version, create the same test user in Firebase Authentication or update this section with the real marker login.

## Running and Testing

Install dependencies and run tests:

```bash
flutter pub get
flutter test
```

Run the app:

```bash
flutter run
```

Force the local demo backend:

```bash
flutter run --dart-define=DEMO_BACKEND=true
```

## Assessment Checklist

- Authentication: sign in, registration, logout, duplicate account errors, weak password errors, and visible user feedback.
- Remote database: Firebase Auth and Firestore repositories are implemented; real Firebase values must be added before final marking.
- CRUD: listings can be created, read in the feed, edited from the listing menu, and deleted after confirmation.
- Device services: listings can attach current device location and a selected photo path.
- Structure: models, repositories, services, controller, and screens are separated.
- Tests: widget tests cover auth validation plus listing create/edit/delete flows; unit tests cover repositories, controller logic, and model mapping.

## App Store Submission

The COMP3130 App Store copy, reviewer instructions, data collection notes and screenshot checklist are in `docs/app_store_submission.md`.

## Marker Notes

The app has been prepared for Android and Chrome testing. Android permissions for location, camera, and media access are declared in `android/app/src/main/AndroidManifest.xml`. iOS usage descriptions are included in `ios/Runner/Info.plist`, although iOS was not the primary target. Photo handling currently stores the selected local image path with the listing; a production version would add Firebase Storage for shared image URLs. Firebase configuration is required before the remote database and authentication features can be assessed against a real backend.
