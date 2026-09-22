# UrbanEaze — Current Work Status

> Last updated: 2026-06-10. Tracks progress against `URBANEAZE_FLUTTER_MASTERPLAN.md`.

## Design system — "Terra" (v2, replaced the generic blue theme)
- [x] Palette: jade `#2A9D8F` primary, terracotta `#E76F51`, sand `#E9C46A`; porcelain light bg `#F6F3EE`, warm charcoal dark bg `#141210` (`core/theme/app_colors.dart`)
- [x] Typography: Sora (display/headings) + Manrope (body/labels) via google_fonts (`app_typography.dart`)
- [x] Full Material 3 theme: inputs, chips, tabs, sheets, dialogs, switches (`app_theme.dart`)
- [x] Component kit (`shared/widgets/common.dart`): MeshBackground (blurred color-blob backdrop), SectionHeader, EmptyState, AvatarCircle, RoleChip, PulsingDot, AnimatedCounter, StatTile, showConfirmSheet, showAppSnack
- [x] GlassNavBar — floating frosted bottom nav with badges, shared by all 3 shells (`resident_shell.dart`)
- [x] Shared ProfileView used by all roles: identity card, theme picker, edit profile, logout (`shared/widgets/profile_view.dart`)

## Data layer
- [x] `core/services/data_service.dart` — all society CRUD + realtime streams: visitors, pre-approvals (OTP create/redeem), announcements, complaints, bookings, join requests, members, car logs + RFID lookup/assign, security reports, SOS
- [x] `shared/providers/data_providers.dart` — Riverpod StreamProviders for everything, keyed off current user's societyCode

## Phase 1 — Foundation & Auth (built earlier, re-skinned by new theme)
- [x] Splash, onboarding, login, register, dashboard selection, society registration, join society, pending approval, session persistence, logout

## Phase 2 — Resident app ✅
- [x] Home: greeting + SOS button, society hero card, live stat tiles, pending-visitor banner, quick actions grid, latest notice
- [x] Visitors: At-the-gate approve/deny, pre-approve sheet (Guest/Delivery/Cab/Daily Help) with 6-digit OTP gate pass + share, history
- [x] Bookings: amenity carousel (from society amenities), 14-day date strip, hourly slot grid with conflict blocking, my bookings + cancel
- [x] Community: notices feed (image/PDF attachments), complaints (file + track), neighbours directory
- [x] Profile (shared ProfileView)

## Phase 3 — Admin app ✅
- [x] Shell with badge counts (join requests, open complaints)
- [x] Home: SOS live banner, stats grid (members/visitors/complaints/requests), latest gate activity, society info
- [x] Members: join request approve/reject, member list with search + role filter, remove member
- [x] Notices: compose + publish, delete with confirm
- [x] Inbox: complaints (mark resolved), security reports from guards, SOS history
- [x] Profile

## Phase 4 — Guard app ✅ (except Bluetooth RFID + camera)
- [x] Shell with pending-approval badge
- [x] Post (home): live duty stats, SOS banner, real-time approval monitor, today's entries
- [x] Entry: OTP gate-pass verification (redeems pre-approval, logs approved entry) + manual visitor form (purpose chips, vehicle toggle)
- [x] Cars: RFID tag lookup/auto-fill + registration, entry/exit logging, recent activity
- [x] Reports: file with severity, history
- [ ] Bluetooth HC-05 RFID auto-read (flutter_blue_plus) — pending
- [ ] Visitor photo capture → Supabase upload — pending

## Phase 5 — Notifications — NOT STARTED
- [ ] FCM push (visitor approval request, announcements), local notification actions, deep links

## Phase 6 — Premium — partial
- [x] OTP gate pass (share via share_plus), SOS alerts (resident → admin/guard banners)
- [ ] QR codes, patrols, analytics, offline mode, parcel flow

## Bug-fix pass for device testing (2026-06-10)
- [x] Added missing `firebase_url` to google-services.json (`https://<project-id>-default-rtdb.firebaseio.com`) — without it every DB call failed at runtime
- [x] Added INTERNET permission + url_launcher queries to AndroidManifest; app label → "UrbanEaze"
- [x] Fresh registrations now get role `''` (not `'pending'`) so they aren't stuck on the waiting screen
- [x] Splash/login route `''`/unknown roles → dashboard selection, `pending` → waiting screen
- [x] Pending-approval screen: handles rejection (→ dashboard selection), refreshes the user profile on approval, cancels its stream on dispose
- [x] Society registration & join flows update the in-memory user (role/societyCode/flat) so dashboards stream data immediately
- [x] Resident visitor badge counts only own-flat pending visitors
- [x] Release APK builds clean: `build\app\outputs\flutter-apk\app-release.apk` (54.7 MB, debug-signed for testing)

## Known gaps / next session
- Old `resident_announcements_screen.dart` removed (folded into Community).
- `flutter analyze`: 0 errors, 1 info left (pre-existing, pending_approval_screen.dart async context).
- Supabase key in app_constants.dart is a placeholder; file/photo upload not wired.
- FCM tokens stored on user model but no push sending yet (needs Cloud Functions or server).
