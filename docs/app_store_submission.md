# COMP3130 App Store Submission

Use this page when filling out the COMP3130 App Store form. It follows the structure shown in the example submissions.

## App Name

Campus Cart

## Short Description

Campus Cart is a Macquarie University marketplace for buying, selling and swapping everyday student items around the Wallumattagal Campus.

## Description

Campus Cart helps Macquarie students arrange small, local exchanges without using a large public marketplace. The app is designed around real campus routines: picking up second-hand COMP3130 notes near 1 Central Courtyard, finding a reusable cup before a coffee run at The Hub, or arranging a quick app-testing swap before demo week.

Macquarie University describes its main campus as the Wallumattagal Campus, with green spaces, accommodation, lifestyle facilities and food outlets. The marketplace uses that campus context directly. Seed listings mention 1 Central Courtyard, The Hub and the Library so reviewers can immediately see that the app has been tailored for MQ rather than a generic eCommerce demo.

Users can register or sign in, request password reset feedback, browse listings, search the marketplace, filter by category, save listings, open a detail screen, create a listing, choose a campus pickup point, attach their current location, optionally pick a photo from the device gallery, edit their own listings and delete listings after confirmation. The app includes Firebase Authentication and Cloud Firestore repository implementations, plus a demo backend fallback so the APK remains easy to test before final Firebase values are added.

## Screenshot Images

Screenshots and the public app description are submitted separately through the COMP3130 App Store site: `http://3.104.146.108/`.

## Reviewer Information

Test account:

- Email: `sein.park@student.mq.edu.au`
- Password: `CampusCart1!`

You can also register a new account from the Register tab.

Testing CRUD:

- Create: tap the floating `Listing` button, enter title, description and price, optionally tap `Location` and `Photo`, then tap `Create listing`.
- Read: sign in and view the marketplace feed. Use search, Saved, Mine and category chips such as Textbooks, Food, Electronics, Services and Other. Each category has at least one seeded MQ-campus listing.
- Update: open the three-dot menu on one of Sein Park's listings, tap `Edit`, change a field, then save.
- Delete: open the three-dot menu on one of Sein Park's listings, tap `Delete`, then confirm in the dialog.

Testing device services:

- Location: on the new listing screen, tap `Location`. The app requests location permission and stores a listing pickup label.
- Photos: on the new listing screen, tap `Photo`. The app opens the device gallery through `image_picker`.

Known limitations:

- The repository is configured for the `campus-cart-seinpark` Firebase project. Email/Password authentication, the marker account and Cloud Firestore must be enabled in the Firebase Console before live marking.
- Picked photos are stored as a local selected file path for assessment demonstration. A production version would upload images to Firebase Storage and store public download URLs in Firestore.
- Device compatibility target: Android APK, Chrome web and iPhone simulator review. iOS deployment target is 15.0 for current Firebase iOS pods.

## App Capabilities and Data Collection

Personal information about users:

- Email address and display name are used for account creation and to show listing contact details.

Data about user's location while using the app:

- Location is only requested when a user explicitly taps `Location` while creating or editing a listing.
- The location is used to label the suggested campus pickup point. There is no background tracking.

Photos or media selected by the user:

- The photo picker is used only when the user taps `Photo` on the listing form.
- The demo stores the selected local path with the listing. No photo is uploaded unless Firebase Storage is added later.

## MQ References Used

- Macquarie University About page: `https://www.mq.edu.au/about`. Used for Wallumattagal Campus context and the campus header image crop in `assets/images/mq_about_banner.png`.
- Macquarie University Cafes, bars and restaurants page: `https://www.mq.edu.au/about/facilities/cafes-bars-restaurants`. Used for The Hub and Central Courtyard food outlet references.
- Macquarie University Central Courtyard precinct page: `https://www.mq.edu.au/about/locations/campus/completed-projects/central-courtyard-precinct`. Used for 1 Central Courtyard social, food and learning precinct references.
