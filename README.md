# Account Keeping — Mobile App (Flutter, iOS & Android)

An owner / accountant app for your **Account Keeping** backend. One Flutter
codebase for iOS and Android, in the teal-and-gold identity.

## Features

- **Login** with your Account Keeping account; **switch between companies**.
- **Dashboard** — Sales, Purchases, Receivable, Payable, Cash, Bank, Net Profit
  for the current financial year (pull to refresh).
- **Invoices** — browse all vouchers with type filters; open any voucher.
- **Create Sale Invoice** — pick a customer, add line items (auto-fills rate &
  GST from your item master), live totals, save. The server posts the balanced
  double-entry and computes CGST/SGST vs IGST.
- **Record Receipt** — money in against a party (bank/cash).
- **Voucher detail** — full invoice view with a **Share** button (send the
  invoice as text via WhatsApp, email, etc.).
- **Parties** — list customers/vendors and add new ones.
- **Products & Services** — list items and add new ones.
- **Reports** — Profit & Loss, Receivable and Payable outstanding.

## Project layout

```
account_keeping_mobile/
  pubspec.yaml
  lib/
    main.dart
    src/
      config.dart            # ← set your API base URL
      theme.dart             # teal & gold theme
      state/session.dart     # token + selected company (persisted)
      api/api_client.dart    # Bearer + X-Company-Id on every call
      api/ak_service.dart    # typed endpoints
      models/models.dart
      screens/               # login, company picker, shell + all screens
  android/app/src/main/AndroidManifest.xml   # INTERNET
  ios/Runner/Info.plist.additions.xml        # display name + ATS (merge)
```

The `lib/`, `pubspec.yaml` and Android manifest are complete. Generate the rest
of the native scaffolding with one Flutter command (below).

## Build & run

```bash
cd account_keeping_mobile

# 1. Generate native android/ + ios/ (preserves the provided lib/, pubspec,
#    and AndroidManifest.xml — flutter create never overwrites existing files).
flutter create --org com.accountkeeping --project-name account_keeping_mobile --platforms=android,ios .

# 2. iOS only: merge ios/Runner/Info.plist.additions.xml into ios/Runner/Info.plist.

# 3. Point the app at your backend (see Configuration).

flutter pub get
flutter run
```

Release:

```bash
flutter build apk --release
flutter build appbundle --release      # Play Store
flutter build ios --release            # then archive in Xcode (needs macOS)
```

## Configuration

Set your API URL in `lib/src/config.dart`, or at run time:

```bash
flutter run --dart-define=API_BASE_URL=https://books.yourdomain.com/api
```

Defaults: `http://10.0.2.2:8000/api` (Android emulator → dev machine),
`http://127.0.0.1:8000/api` for the iOS simulator.

## How auth works

The app calls `POST /auth/login` → token, then `GET /auth/me` for the user's
companies. The token + selected company id are stored with `shared_preferences`
and sent as `Authorization: Bearer …` + `X-Company-Id: …` on every request —
exactly like the web app. Log out clears them.

## Demo login (against the sample backend)

- Email: `mobiledemo@ak.in`  ·  Password: `password123`  ·  Company: *Skyline Traders*

(Or any of your existing Account Keeping logins.)

## Notes

- Sharing uses the OS share sheet (`share_plus`) — sends a clean text summary of
  the invoice. A PDF export can be added with the `printing` package if you want
  pixel-perfect invoices.
- The app is read + write: creating invoices/receipts posts real vouchers to your
  books, so use a test company while evaluating.
