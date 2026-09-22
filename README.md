# UrbanEaze

A society (gated-community) management app built with Flutter — three role-based apps in one codebase: **Resident**, **Admin**, and **Guard**. Think MyGate / NoBrokerHood: visitor approvals at the gate, OTP gate passes, amenity bookings, notices, complaints and RFID car logging, all backed by Firebase Realtime Database streams.

> **Status: work in progress.** The three role apps are functional end-to-end, but push notifications, hardware RFID and file uploads are not wired up yet. See [Project status](#project-status) for the honest breakdown.

## Features

**Resident**
- Home with live society stats, SOS button, pending-visitor banner, latest notice
- Visitors — approve/deny at the gate, pre-approve a guest/delivery/cab/daily-help with a 6-digit OTP gate pass you can share
- Bookings — amenity carousel, 14-day date strip, hourly slot grid with conflict blocking
- Community — notices feed with attachments, file and track complaints, neighbours directory

**Admin**
- Join-request approve/reject, member list with search and role filter
- Compose and publish notices
- Inbox — complaints, guard security reports, SOS history
- Live SOS banner and gate-activity feed

**Guard**
- OTP gate-pass verification (redeems the pre-approval and logs the entry)
- Manual visitor entry with purpose chips and vehicle toggle
- Car RFID tag lookup / registration, entry-exit logging
- File security reports with severity

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart SDK ^3.12.1) |
| State | Riverpod 2.x |
| Navigation | GoRouter (role-based routing) |
| Auth | Firebase Auth |
| Database | Firebase Realtime Database |
| File storage | Supabase Storage *(not yet wired)* |
| Push | FCM *(not yet wired)* |
| Local storage | shared_preferences + Hive |
| Bluetooth | flutter_blue_plus *(not yet wired)* |

## Design system — "Terra"

A custom Material 3 theme, not a template look. Jade `#2A9D8F` primary, terracotta `#E76F51`, sand `#E9C46A`; porcelain light background `#F6F3EE` and warm charcoal dark `#141210`. Sora for display/headings, Manrope for body. Light and dark both supported, following the system setting with an in-app override.

Shared component kit lives in `lib/shared/widgets/common.dart` — mesh backdrop, section headers, empty states, stat tiles, animated counters, confirm sheets — plus a frosted floating `GlassNavBar` shared by all three role shells.

## Project layout

```
lib/
├── core/
│   ├── constants/      # DB paths, prefs keys, role + status constants
│   ├── router/         # GoRouter config, role-based redirects
│   ├── services/       # auth, society, and the society-wide data service
│   └── theme/          # Terra colors, typography, Material 3 theme
├── features/
│   ├── auth/           # splash, onboarding, login, register, join/create society
│   ├── resident/       # home, visitors, bookings, community, profile
│   ├── admin/          # home, members, notices, inbox, profile
│   └── guard/          # post, entry, cars, reports
└── shared/
    ├── models/         # user, society, visitor, announcement, complaint, booking
    ├── providers/      # Riverpod stream providers keyed off the user's society
    └── widgets/        # design-system component kit
```

## Getting started

You need your own Firebase project — the config for this one is deliberately not committed.

1. **Clone and install**
   ```bash
   git clone https://github.com/hopepranav08/urbaneaze.git
   cd urbaneaze
   flutter pub get
   ```

2. **Set up Firebase**
   - Create a Firebase project with **Authentication** (email/password) and **Realtime Database** enabled.
   - Add an Android app with package name `com.urbaneaze.urbaneaze`.
   - Download its `google-services.json` into `android/app/`. Use [`android/app/google-services.json.example`](android/app/google-services.json.example) as a reference for the shape — make sure `firebase_url` is present, or every database call fails at runtime.
   - Write Realtime Database security rules before putting anything real in it. The defaults are wide open.

3. **Optional — Supabase storage** for notice attachments and visitor photos: set `supabaseUrl`, `supabaseAnonKey` and `supabaseBucket` in `lib/core/constants/app_constants.dart`. Upload is not implemented yet, so you can skip this.

4. **Run**
   ```bash
   flutter run
   ```

Android is the only platform that has been tested. The iOS, web, macOS, Linux and Windows folders are stock Flutter scaffolding and have no Firebase config.

## Project status

| Area | State |
|---|---|
| Foundation & auth | Done — splash, onboarding, login/register, society create/join, pending approval, session persistence |
| Design system "Terra" | Done |
| Data layer | Done — full CRUD + realtime streams, Riverpod providers |
| Resident app | Done |
| Admin app | Done |
| Guard app | Done, except the two items below |
| Bluetooth HC-05 RFID auto-read | Not started |
| Visitor photo capture + upload | Not started |
| Push notifications (FCM) | Not started — tokens are stored on the user model, but nothing sends |
| QR codes, patrols, analytics, offline mode, parcels | Not started |

Known gaps:
- Supabase key in `app_constants.dart` is a placeholder; file and photo upload are not wired.
- Release builds are signed with the debug key — see the TODO in `android/app/build.gradle.kts`. Not Play Store ready.
- `flutter analyze` is clean apart from one pre-existing info in `pending_approval_screen.dart`.

Detailed planning lives in [`URBANEAZE_FLUTTER_MASTERPLAN.md`](URBANEAZE_FLUTTER_MASTERPLAN.md); running progress notes in [`current_work.md`](current_work.md).
