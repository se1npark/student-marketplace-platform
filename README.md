# Campus Cart

**Tagline:** Buy, sell, and swap useful things around Macquarie's Wallumattagal Campus.

Campus Cart is a Flutter marketplace app for students who want a safer, smaller alternative to large public resale sites. The app focuses on everyday Macquarie exchanges: COMP3130 notes near 1 Central Courtyard, food and coffee items around The Hub, chargers and study equipment near the Library, umbrellas for Metro walks, and student-to-student services such as app testing swaps. A student can sign in, search and filter current listings, open a detailed listing page, save useful listings, create their own listing, attach a campus pickup point, optionally attach a photo path, edit the listing later, and delete it when it is sold.

The app is a focused major project demonstration rather than a full commercial product. Its main data entity is a `Listing`, stored through a repository layer that supports create, read, update, and delete operations. Firebase Authentication and Cloud Firestore implementations are included, with an in-memory demo backend used automatically while Firebase options still contain placeholders.

## Main Features

- Email/password authentication with sign in, registration, logout, reset-password feedback, Firebase-ready and demo implementations.
- Marketplace feed that reads listings from the listing repository in real time, with loading, empty and error states.
- Search, Saved and Mine views so students can narrow the marketplace and return to useful posts.
- Listing detail screen with image, price, seller, pickup point, save toggle, edit and delete actions.
- Category filters for Textbooks, Food, Electronics, Services, and Other.
- Create, edit, and delete listing flows with validation, confirmation dialogs, loading states and success messages.
- Listing fields for title, description, category, condition, price, seller, contact email, optional image path, and optional location.
- Mobile device service integration through current device location using `geolocator`.
- Optional photo selection using `image_picker`.
- Unit and widget tests that run with `flutter test`, including interaction tests.
- MQ-specific seed listings, generated item images, campus pickup labels, and a marketplace header image sourced from the Macquarie University About page.

## Users

The primary users are Macquarie students who need quick, local exchanges with people already on campus. A first persona is Alex, a second-year computing student who buys used textbooks and sells old electronics after each session. Alex prefers Campus Cart over Facebook Marketplace because listings are scoped to campus and include student contact details. A second persona is Priya, a first-year student who wants affordable study items and uses search, saved listings, and category filters to avoid scrolling through unrelated products.

These users choose Campus Cart because it is lightweight and task-focused. They do not need auctions, shipping, public profiles, or complex payments. The app supports the practical campus handover: find an item, check the price and condition, see where the seller can meet, and contact them through their student email.

The campus context is based on Macquarie's official pages: the main campus is the Wallumattagal Campus, and MQ describes 1 Central Courtyard as a major social, food and learning precinct.

## Technical Details

This project is built with Flutter and Dart. The current codebase uses a small layered structure:

- `lib/models`: `CampusUser`, `Listing`, `ListingDraft`, and `ListingLocation`.
- `lib/repositories`: abstract repositories plus Firebase and memory implementations.
- `lib/services`: device integrations for location and image picking.
- `lib/controllers`: `AppController`, the app state class used by the screens.
- `lib/screens`: authentication, marketplace, listing detail, and listing form screens.
- `lib/widgets`: reusable listing image rendering.
- `test`: repository and widget tests.

The production backend path is `FirebaseAuthRepository` for sign in, registration, password reset and sign out, plus `FirestoreListingRepository` for listing CRUD in the `listings` collection.

The app is configured for the `campus-cart-seinpark` Firebase project. For marking, enable Email/Password authentication, create the test user below, and create a Cloud Firestore database for the `listings` collection.

## Test User

Firebase test login:

- Email: `sein.park@student.mq.edu.au`
- Password: `CampusCart1!`

Demo mode is still available for local fallback with `--dart-define=DEMO_BACKEND=true`.

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

The implementation covers authentication, Firestore-ready remote data, listing CRUD, location and photo device services, separated project structure, and tests for auth validation, create/edit/delete/search/detail flows, repositories, controller logic, and model mapping.

## App Store Submission

The COMP3130 App Store copy, reviewer instructions and data collection notes are in `docs/app_store_submission.md`. iPhone-sized screenshots and the public submission page are uploaded separately through the COMP3130 App Store site.

## Marker Notes

The app is prepared for Android, Chrome and iPhone simulator review. Android permissions are declared in `android/app/src/main/AndroidManifest.xml`; iOS usage descriptions are in `ios/Runner/Info.plist`, with iOS target 15.0 for current Firebase pods. Photo handling stores the selected local image path; a production version would add Firebase Storage. The Firebase app configuration is present; the Firebase Console still needs Email/Password authentication, the marker account, and Cloud Firestore enabled before live marking.
