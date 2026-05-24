# Campus Cart

**Tagline:** Buy, sell, and swap useful things around Macquarie's Wallumattagal Campus.

Campus Cart is a Flutter marketplace app for Macquarie students who want a smaller and safer campus-focused alternative to large public resale sites. It supports everyday exchanges such as COMP3130 notes near 1 Central Courtyard, lunch vouchers around The Hub, chargers near the Library, umbrellas for Metro walks, and student-to-student services such as app testing swaps.

Students can sign in, browse a live marketplace feed, filter by category, search by keyword, save listings, open detailed listing pages, contact sellers by email, create their own posts, upload photos, attach campus pickup points, edit posts later, and delete listings when they are no longer available. The app is a major-project demonstration, but it uses real Firebase Authentication, Cloud Firestore, and Cloudinary-backed image hosting for live marking.

## Main Features

- Email/password authentication with sign in, registration, logout, password reset feedback, Firebase and demo implementations.
- Live listing feed backed by a repository layer, with loading, empty, and error states.
- Category filters for Textbooks, Food, Electronics, Services, and Other.
- Keyword search across listing title, description, category, and pickup label.
- Saved and Mine tabs so students can revisit bookmarked listings and manage their own posts.
- Saved listing IDs persist on the device with `shared_preferences`, so bookmarks remain after restarting the app.
- Listing detail screen with image, price, condition, seller name, contact email, pickup point, save toggle, edit, and delete actions.
- Contact seller button opens the device email app through a `mailto:` link, with a fallback snackbar if no email app is available.
- Create, edit, and delete listing flows with form validation, confirmation dialogs, loading states, and success messages.
- Photo selection through `image_picker`, uploaded to Cloudinary so listing images display across Android, iOS, Chrome, and macOS.
- Campus pickup support through quick MQ location chips, current GPS location via `geolocator`, and a Campus map picker.
- Campus map picker lets users search official MQ spots or tap a custom campus pin, including MQ Library, MUSE, Macquarie University Station, Wally's Coffee Cart, Sport & Aquatic Centre, and Central Courtyard.
- Unit and widget tests covering model mapping, image rendering, authentication validation, registration, search, saved listings, mine listings, listing details, sign out, and CRUD flows.

## Users

The main users are Macquarie students who need fast, local exchanges with people already on campus. Alex, a second-year computing student, buys used textbooks and sells old electronics after each session. Alex prefers Campus Cart over Facebook Marketplace because listings are scoped to campus, include pickup locations, and expose seller contact details.

Priya, a first-year student, wants affordable study items without scrolling through unrelated products. She uses category filters, search, and saved listings to find relevant posts before class. These users choose Campus Cart because they do not need auctions, shipping, public profiles, or complex payments. The app supports the practical campus handover: find an item, check condition and price, see where to meet, then contact the seller through student email.

## Technical Details

This project is built with Flutter and Dart. The codebase uses a small layered structure:

- `lib/models`: `CampusUser`, `Listing`, `ListingDraft`, and `ListingLocation`.
- `lib/repositories`: abstract repositories plus Firebase and memory implementations.
- `lib/services`: location, image picking, Cloudinary photo upload, and supporting services.
- `lib/controllers`: `AppController`, which manages app state, filtering, saved IDs, and CRUD actions.
- `lib/screens`: authentication, marketplace, listing detail, and listing form screens.
- `lib/widgets`: reusable listing image rendering.
- `test`: model, controller, image, and widget tests.

The production backend path is `FirebaseAuthRepository` for sign in, registration, password reset, and sign out, `FirestoreListingRepository` for listing CRUD in the `listings` collection, and `CloudinaryListingPhotoStorage` for listing image uploads. The app is configured for the `campus-cart-seinpark` Firebase project. Email/Password authentication is enabled, and Firestore stores marketplace records.

## Test User

Firebase test login:

- Email: `sein.park@students.mq.edu.au`
- Password: `CampusCart1!`

Demo mode is still available for local fallback:

```bash
flutter run --dart-define=DEMO_BACKEND=true
```

## Running and Testing

Install dependencies, run tests, and start the app:

```bash
flutter pub get
flutter test
flutter run
```

## Marker Notes

The app has been checked on Android emulator, iPhone simulator, Chrome, and macOS. The submitted APK is the Android build for marking. Android permissions are declared in `android/app/src/main/AndroidManifest.xml`, and iOS usage descriptions are in `ios/Runner/Info.plist`. Selected images preview locally during editing, then save as HTTPS Cloudinary URLs in Firestore so they render consistently across devices. The assessment coverage includes authentication, Firestore remote data, listing CRUD, saved-list persistence, contact seller email flow, location/photo device services, campus map pickup selection, separated structure, and automated tests.
