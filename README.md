# Aapka Aadhaar

A doorstep Aadhaar services platform built with Flutter and Firebase. Instead of queueing at an
enrolment centre, a citizen books a time slot from the app and a verified operator visits their
address to complete the enrolment or update.

The repository contains two separate Flutter applications that share one Firebase Realtime Database:

| App | Directory | Used by |
| --- | --- | --- |
| **Aapka Aadhaar** | [`aapka_aadhaar/`](aapka_aadhaar) | Citizens booking a service |
| **Aapka Aadhaar Operator** | [`aapka_aadhaar_operator/`](aapka_aadhaar_operator) | Field operators fulfilling bookings |

Screenshots: https://drive.google.com/drive/folders/1O69CfoRwDO2yYAiqeJ36XHa72RlFWOzn

## Features

### Citizen app

- **Phone-number authentication** — registration and login via Firebase Auth with OTP verification.
- **Service requests** — two flows, *new enrolment* and *update*. Update requests let the user pick
  which fields to change: Name, Address, Date of Birth, Gender, Mobile/Email, and Biometric.
- **Guest entries** — a single booking can cover multiple people at the same address.
- **Slot booking** — hourly slots (10–11, 11–12, 12–1, 2–3 … 5–6) with live availability, so slots
  already taken by another user show as booked.
- **Payments** — Cash on Service, or online payment through Razorpay.
- **Operator verification** — before the visit begins, the citizen enters an OTP that the operator
  provides, confirming the person at the door is the assigned operator.
- **Live tracking** — Google Maps view of the operator's location with a route drawn using the
  OpenRouteService directions API.
- **Booking management** — view booking details, reschedule to a different slot, and browse
  previous bookings.
- **Feedback** — star rating and feedback form after a completed visit.
- **Profile, press releases, contact and about pages**, plus an intro carousel on first launch.

### Operator app

- Phone-number authentication with OTP.
- Home dashboard showing the operator's own slots as booked or vacant.
- Booking details for each assigned visit, with the citizen's address and requested services.
- Navigation to the citizen's location on Google Maps.
- Profile with photo upload to Firebase Storage, and previous bookings history.

## Tech stack

- **Flutter** (Dart SDK `>=2.17.6 <3.0.0`), Material Design, Poppins as the app font
- **Firebase** — Auth (phone OTP), Realtime Database, Storage
- **Google Maps** (`google_maps_flutter`) with `location` / `geolocator` for positioning
- **OpenRouteService** for route geometry between operator and citizen
- **Razorpay** (`razorpay_flutter`) for online payments
- `shared_preferences` for session persistence, `image_picker`, `permission_handler`,
  `form_field_validator`, `flutter_rating_bar`, `intro_slider`

## Data model

Both apps read and write the same Realtime Database tree:

```
users/           citizen profiles and their bookings
operators/       operator profiles, current location, availability
slots/           per-operator slot occupancy
guests/          additional people covered by a booking
previousBookings/ completed visit history
feedbacks/       ratings and comments
```

## Getting started

### Prerequisites

- Flutter SDK 3.x with a Dart SDK in the `>=2.17.6 <3.0.0` range
- Android Studio or Xcode for the platform you are targeting
- A Firebase project with Phone Authentication, Realtime Database, and Storage enabled

### Setup

Each app is an independent Flutter project, so run these steps in whichever one you want to build.

```bash
git clone https://github.com/soham-dixit/mobile-operator-booking-platform.git
cd mobile-operator-booking-platform/aapka_aadhaar   # or aapka_aadhaar_operator
flutter pub get
flutter run
```

To point the apps at your own Firebase project, replace `android/app/google-services.json` (and the
iOS `GoogleService-Info.plist`) with the files generated for your project.

### API keys

The apps depend on three external credentials:

- **Google Maps** — set your key in `android/app/src/main/AndroidManifest.xml` and
  `ios/Runner/AppDelegate.swift`.
- **OpenRouteService** — used in `lib/services/network_helper.dart` for route directions.
- **Razorpay** — the checkout key used in `lib/pages/service_req.dart` (citizen app only).

> **Note:** the keys currently committed in this repository are development keys and are visible in
> the git history. Rotate them and load them from environment configuration before any real
> deployment.

## Project structure

```
aapka_aadhaar/lib/
├── main.dart                  app entry, Firebase init, session restore
├── splash_screen.dart
├── authentication/            login, registration, OTP
├── pages/                     home, service request, slot booking, tracking,
│                              bookings, profile, feedback, static pages
├── services/                  network_helper (routing), otp_verification
├── widgets/                   shared widgets (progress dialog)
└── global/                    shared app state
```

The operator app follows the same layout with a smaller `pages/` set.
