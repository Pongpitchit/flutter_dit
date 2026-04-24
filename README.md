# Thai Coffee House (DIT207)

Flutter mobile app for ordering coffee with authentication, cart, checkout, and order history.

## Features

- Login / Sign up with backend API
- View coffee menu from API
- Product detail screen
- Add to cart and update quantity
- Checkout and submit order
- View order history
- Edit profile (username, full name, phone)

## Tech Stack

- Flutter (Dart)
- `http` for REST API calls
- `shared_preferences` for local persistence (token, cart)

## Project Structure

- `lib/main.dart` - app entry point
- `lib/screens/` - UI screens
  - `login_screen.dart`
  - `signup_screen.dart`
  - `home_screen.dart`
  - `list_screen.dart`
  - `detail_screen.dart`
  - `cart_screen.dart`
  - `order_history_screen.dart`
- `lib/models/` - data models (`user`, `coffee`, `cart_item`, etc.)
- `lib/services/` - services (`auth_service`, `cart_service`)

## API Base URL

`https://apicoffee-flutter.vercel.app`

Main endpoints used:

- `POST /api/auth/login`
- `POST /api/auth/register`
- `GET /api/coffees`
- `POST /api/orders`
- `GET /api/orders`
- `PATCH /api/users/:id`
- `DELETE /api/users/account`

## Prerequisites

- Flutter SDK 3.x+
- Dart SDK (comes with Flutter)
- Android Studio / Xcode / VS Code / Cursor

## Getting Started

1. Install dependencies:

```bash
flutter pub get
```

2. Run app:

```bash
flutter run
```

## Build

Android:

```bash
flutter build apk
```

iOS:

```bash
flutter build ios
```

## Notes

- App theme uses Thai coffee style colors and `Sarabun` font.
- Cart data and auth token are stored locally with `shared_preferences`.
- Order history and menu depend on backend API availability.
