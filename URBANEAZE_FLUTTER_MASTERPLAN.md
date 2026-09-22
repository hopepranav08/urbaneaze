# UrbanEaze Flutter — Complete Rebuild Master Plan
> Reference: MyGate + NoBrokerHood feature parity | Premium custom UI | Play Store ready

---

## VISION

A premium society management app targeting **MyGate/NoBrokerHood-level quality**:
- 3 dedicated apps in one: **Resident App**, **Admin App**, **Guard App**
- Real-time everything: visitor approvals, gate entry, announcements, bookings
- Hardware integrations: Bluetooth RFID, boom barriers (future)
- Offline-capable guard flow
- Play Store deployable

---

## TECH STACK

| Layer | Choice | Reason |
|---|---|---|
| Framework | Flutter (latest stable) | Single codebase, top UI, Play Store ready |
| Language | Dart | Flutter native |
| Auth | Firebase Auth | Current project, keep same |
| Database | Firebase Realtime DB | Current project, keep same |
| File Storage | Supabase Storage | Current project, keep same |
| Push Notifications | Firebase Cloud Messaging (FCM) | Industry standard |
| State Management | Riverpod 2.x | Most scalable, best DX |
| Navigation | GoRouter | Declarative, role-based routing |
| HTTP | Dio | Better than OkHttp equivalent |
| Bluetooth | flutter_blue_plus | Best maintained BLE/Classic |
| Local Storage | shared_preferences + Hive | Lightweight + structured cache |
| Image | cached_network_image + image_picker | Standard |
| Animations | flutter_animate + Lottie | Premium feel |
| Date/Time | intl package | Dart native |
| Notifications (local) | flutter_local_notifications | Visitor popup replacement |
| PDF/Files | open_filex + file_picker | For announcement attachments |
| UI Components | Custom Design System (see below) | Zero-template look |

---

## DESIGN SYSTEM — "UrbanEaze Modern"

Supports **both Light and Dark themes** with adaptive glassmorphism.
Theme auto-follows system setting; user can override in-app.

---

### DARK THEME

```dart
// Backgrounds
darkBg:           #0D1117  // GitHub-dark level depth
darkSurface:      #161B22  // Card bg
darkSurfaceHigh:  #1C2333  // Elevated card / modal
darkBorder:       rgba(255,255,255, 0.08)

// Glassmorphism (dark)
glassBackground:  rgba(22, 27, 34, 0.70)
glassBorder:      rgba(255,255,255, 0.10)
glassBlur:        20px (BackdropFilter)

// Text
darkTextPrimary:  #F0F6FC
darkTextSecondary:#8B949E
darkTextMuted:    #484F58
```

### LIGHT THEME

```dart
// Backgrounds
lightBg:          #F5F7FA  // Soft off-white
lightSurface:     #FFFFFF  // Card bg
lightSurfaceHigh: #EEF2F7  // Subtle elevated bg
lightBorder:      rgba(0,0,0, 0.08)

// Glassmorphism (light)
glassBackground:  rgba(255, 255, 255, 0.60)
glassBorder:      rgba(255,255,255, 0.80)
glassBlur:        20px (BackdropFilter)

// Text
lightTextPrimary:  #0D1117
lightTextSecondary:#57606A
lightTextMuted:    #AFB8C1
```

### SHARED ACCENT COLORS (same in both themes)

```dart
primary:        #4F8EF7  // Electric blue — CTAs, active states
primaryLight:   #A5C8FF  // Hover/soft tint
secondary:      #2EBFA5  // Teal — success actions, online status
danger:         #F85149  // Alert red — deny, delete
warning:        #F0A83A  // Amber — pending, caution
success:        #3FB950  // Green — approved, confirmed

// Role colors
adminColor:     #B040FF  // Purple — admin badges
residentColor:  #4F8EF7  // Blue — resident
guardColor:     #F0A83A  // Amber — guard

// Gradients
heroDark:       linear(135deg, #4F8EF7 → #2EBFA5)
heroLight:      linear(135deg, #667EEA → #764BA2)
cardGradDark:   linear(180deg, #1C2333 → #161B22)
cardGradLight:  linear(180deg, #FFFFFF → #EEF2F7)
dangerGrad:     linear(135deg, #F85149 → #FF6B35)
approveGrad:    linear(135deg, #3FB950 → #2EBFA5)
```

### Typography
- Font: **Inter** (Google Fonts — thin to black weights)
- Display: 32px / 700 weight
- Heading: 24px / 600
- Title: 18px / 600
- Subtitle: 16px / 500
- Body: 14px / 400
- Caption: 12px / 400
- Label: 11px / 500 UPPERCASE

### Glassmorphism Rules
- Use `BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20))`
- Card background: theme-appropriate glass color (60–70% opacity)
- Border: 1px solid with low opacity white/black
- Border radius: 16px (cards), 24px (modals), 12px (chips), 8px (buttons)
- Always place glass cards over a gradient or image background
- Shadow: `BoxShadow(blurRadius: 24, offset: Offset(0,8), color: rgba(0,0,0,0.15))`

### Component Library
```
GlassCard          — frosted glass, adaptive light/dark
GradientButton     — primary CTA, animated scale on press
OutlineButton      — secondary action
StatusBadge        — Pending (amber), Approved (green), Denied (red), Active (blue)
RoleChip           — Admin (purple), Resident (blue), Guard (amber) with icon
AvatarCircle       — initials or photo, with online PulsingDot
AvatarStack        — overlapping avatars (max 4 + overflow count)
AnimatedCounter    — smooth number tick-up for dashboard stats
PulsingDot         — live indicator (green = online/active)
DragHandle         — bottom sheet handle bar
ToastBanner        — slide-in top toast (success/error/info)
ConfirmSheet       — bottom sheet confirmation with glass bg
SectionHeader      — label + optional action link
EmptyStateWidget   — illustration + message + CTA
LoadingShimmer     — skeleton screen placeholders
ThemeToggle        — sun/moon animated switch
```

### Animations
- Page transitions: Fade + slide-up (250ms, ease-out curve)
- Card entrance: Staggered fade-up (50ms delay between items)
- Button press: Scale 0.96 + haptic feedback
- Approval action: Full-screen green radial expand + checkmark Lottie
- Denial action: Red flash + X Lottie
- Loading: Lottie spinner (custom branded)
- Bottom nav icon: Scale + color transition (200ms)
- Theme switch: Crossfade (400ms)

### Bottom Navigation Style
- Floating bottom bar with glass background
- Rounded top corners (24px)
- Active tab: filled icon + color + scale-up label
- Inactive tab: outline icon + muted color
- Notification badge: red dot with count

---

## USER ROLES & APP STRUCTURE

```
UrbanEaze
├── Resident App  (Members/Owners/Tenants)
├── Admin App     (Society Committee/RWA)
└── Guard App     (Watchman/Security)
```

All 3 roles live in one Flutter app. Role-based routing via GoRouter after login.

---

## FIREBASE DATA ARCHITECTURE (Rebuilt & Clean)

```
/users/{userId}
  name, email, phone, occupancy, carNumber, role,
  societyCode, flatNumber, profileImageUrl, fcmToken,
  createdAt, isActive

/societies/{societyCode}
  societyName, address, numOfFlats, contactPerson, contactNumber,
  amenities[], adminId, societyCode, createdAt
  
  /members/{userId}
    username, role, flatNumber, fcmToken, isActive
    
  /flats/{flatNumber}
    ownerName, ownerId, tenants[]
    
  /announcements/{id}
    text, fileUrl, fileType, postedBy, timestamp
    
  /complaints/{id}
    title, message, name, flatNumber, category,
    status, priority, timestamp, resolvedAt
    
  /visitorLogs/{id}
    name, phone, purpose, customPurpose, flat,
    hasCar, rfidTag, carNumber, imageUrl,
    status (Pending/Approved/Denied),
    watchmanId, residentId, timestamp, exitTimestamp
    
  /preApprovals/{id}
    residentId, flat, visitorName, visitorPhone,
    purpose, date, time, otp, isRecurring,
    isUsed, createdAt
    
  /facilityBookings/{amenity}/{date}/{id}
    userId, userName, flatNumber, amenity,
    date, startTime, endTime, societyCode, status
    
  /carRFIDTags/{rfid}
    carNumber, ownerName, flatNumber, assignedAt
    
  /carLogs/{id}
    rfidTag, carNumber, ownerName, flatNumber,
    timestamp, direction (in/out)
    
  /payments/{id}
    amount, type, userId, flatNumber,
    status, timestamp, receiptUrl
    
  /dailyHelp/{id}
    name, role, phone, imageUrl, passcode,
    assignedFlat, isActive, createdAt
    
  /securityReports/{id}
    title, description, watchmanId, watchmanName,
    severity, timestamp, imageUrl
    
  /vendors/{id}
    name, category, phone, email,
    address, rating, addedBy, timestamp
    
  /patrols/{id}
    watchmanId, startTime, endTime,
    checkpoints[], status
    
/joinRequests/{id}
  userId, societyCode, userName, role,
  flatNumber, status, createdAt
```

---

## COMPLETE FEATURE LIST (All Phases)

### PHASE 1 — Foundation & Auth
- [ ] Flutter project scaffolding with folder structure
- [ ] Design system (colors, typography, components)
- [ ] Firebase + Supabase integration (FlutterFire CLI)
- [ ] Riverpod state management setup
- [ ] GoRouter role-based navigation
- [ ] Splash screen (animated logo)
- [ ] Onboarding screens (3-screen walkthrough)
- [ ] Login screen (email/password, form validation)
- [ ] Register screen (name, email, password, phone, occupancy, car)
- [ ] Dashboard selection (Admin / Resident / Watchman)
- [ ] Society registration (Admin only, amenities picker)
- [ ] Join society flow (societyCode + flatNumber)
- [ ] Pending approval waiting screen
- [ ] Session persistence (auto-login)
- [ ] Logout with session clear

### PHASE 2 — Resident Dashboard
- [ ] Home screen (greeting, society stats, quick actions)
- [ ] Bottom navigation (Home, Visitors, Bookings, Community, Profile)
- [ ] Visitor request cards (pending approvals for own flat)
- [ ] One-tap Approve / Deny with animation
- [ ] Pre-approve visitor (Guest, Delivery, Cab, Daily Help)
- [ ] Pre-approval OTP generation and display
- [ ] Visitor history log (own flat, filterable)
- [ ] Car logs (own flat)
- [ ] Announcement feed (text + image + PDF)
- [ ] Complaints — file + track status
- [ ] Facility booking (calendar + time slots + amenity selector)
- [ ] My bookings view + cancel
- [ ] Vendor directory
- [ ] Payment history
- [ ] Daily help management (add, passcode, entry/exit logs)
- [ ] Member directory (read-only)
- [ ] SOS / Panic button (FCM alert to admin + guards)
- [ ] Profile screen (edit name, phone, car, photo)
- [ ] Push notification handler (visitor popup, announcements)

### PHASE 3 — Admin Dashboard
- [ ] Home screen (society overview stats, pending actions count)
- [ ] Bottom navigation (Home, Members, Announcements, Reports, Profile)
- [ ] Join request management (approve / reject with bulk select)
- [ ] Member list (all members, filter by role/flat)
- [ ] Member detail view
- [ ] Post announcement (text + file upload to Supabase)
- [ ] Announcement management (delete, edit)
- [ ] Complaints inbox (view all, filter by status/priority)
- [ ] Mark complaint resolved
- [ ] Facility bookings overview
- [ ] All visitor logs (society-wide)
- [ ] All car logs (society-wide)
- [ ] Vendor management (add, edit, remove)
- [ ] Security reports view
- [ ] Society settings (edit amenities, society info)
- [ ] Admin profile

### PHASE 4 — Guard Dashboard
- [ ] Home screen (stats: today's visitors, cars, reports)
- [ ] Bottom navigation (Home, Visitor Entry, Car/RFID, Reports, Profile)
- [ ] Visitor entry form:
  - Name, phone, purpose (dropdown + custom)
  - Flat selection (searchable, shows owner name)
  - Camera capture (visitor photo → Supabase upload)
  - Guest has car switch + RFID + car number
  - Submit → resident notification sent
- [ ] Real-time pending approvals monitor
- [ ] Visitor log (guard's entries today + history)
- [ ] Car entry screen (RFID auto-populate via Bluetooth + manual)
- [ ] RFID tag assignment (link tag → car number → flat)
- [ ] Car logs view (today + search by flat/car)
- [ ] Bluetooth RFID service (HC-05, CarEntryService replacement in Flutter)
- [ ] Security report filing (title, description, severity, photo)
- [ ] Security reports history
- [ ] Facility booking verification (scan/check booking validity)
- [ ] Guard profile

### PHASE 5 — Notifications & Real-time
- [ ] FCM push notifications (visitor, announcement, complaint update)
- [ ] In-app visitor popup with Approve/Deny actions (notification actions)
- [ ] Background service for visitor monitoring (flutter_background_service)
- [ ] Real-time badge counts on bottom nav
- [ ] Notification history screen
- [ ] Deep link from notification → relevant screen

### PHASE 6 — Premium Features (Post-MVP)
- [ ] Pre-approval QR code generation (resident generates, guard scans)
- [ ] Guard patrol with QR checkpoints
- [ ] Daily help biometric / passcode entry tracking
- [ ] WhatsApp OTP sharing (via share_plus)
- [ ] Society analytics dashboard (admin)
- [ ] Multi-society support (admin manages multiple societies)
- [ ] Overstay alerts (visitor stayed > X hours)
- [ ] Child exit control
- [ ] Parcel / leave-at-gate flow
- [ ] Offline mode for guard (Hive cache + sync queue)

---

## FOLDER STRUCTURE

```
flutter_urbaneaze/
├── lib/
│   ├── main.dart
│   ├── app.dart                    # App widget, theme, router
│   ├── core/
│   │   ├── theme/                  # Colors, typography, component themes
│   │   ├── router/                 # GoRouter config, guards
│   │   ├── services/               # Firebase, Supabase, FCM, Bluetooth
│   │   ├── utils/                  # Helpers, validators, formatters
│   │   └── constants/              # Firebase paths, enums, strings
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/               # AuthRepository
│   │   │   ├── domain/             # Auth models, states
│   │   │   └── presentation/       # Login, Register, Onboarding screens
│   │   ├── admin/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── resident/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── guard/
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   ├── visitor/                # Shared visitor logic
│   │   ├── facility/               # Shared booking logic
│   │   ├── announcements/          # Shared announcement logic
│   │   ├── complaints/             # Shared complaints logic
│   │   └── notifications/          # FCM + local notifications
│   └── shared/
│       ├── widgets/                # Design system components
│       ├── models/                 # Shared data models
│       └── providers/              # Shared Riverpod providers
├── assets/
│   ├── images/
│   ├── icons/
│   ├── animations/                 # Lottie JSON files
│   └── fonts/                      # Inter font family
├── android/                        # Android config (keep google-services.json)
├── ios/                            # iOS config (future)
└── pubspec.yaml
```

---

## BUILD PHASES & TIMELINE

| Phase | What | Estimated Time |
|---|---|---|
| 0 | Flutter SDK setup + Doctor | User does this (15 min) |
| 1 | Project scaffold + Design system + Auth | 2-3 days |
| 2 | Resident dashboard (all features) | 3-4 days |
| 3 | Admin dashboard (all features) | 2-3 days |
| 4 | Guard dashboard + Bluetooth RFID | 3-4 days |
| 5 | Notifications (FCM + local) | 1-2 days |
| 6 | Testing + Polish + Play Store prep | 2-3 days |
| **Total** | **Full MVP** | **~3 weeks** |

---

## PLAY STORE REQUIREMENTS (Track from Day 1)

- [ ] App icon (512x512 + adaptive icon)
- [ ] Feature graphic (1024x500)
- [ ] Screenshots (phone + tablet)
- [ ] Privacy policy URL (required for apps with personal data)
- [ ] App signing key (generate once, NEVER lose it)
- [ ] Target SDK 34+ (current requirement)
- [ ] Permissions justification (Bluetooth, Camera, Notifications)
- [ ] proguard/R8 rules for Firebase + Supabase
- [ ] Build release APK / AAB

---

## KEY DECISIONS VS CURRENT APP

| Current (Java) | Flutter Rebuild | Why |
|---|---|---|
| XML layouts (73 files) | Single Dart widget tree | Less code, live reload |
| Multiple activities (36) | GoRouter + screens | Cleaner navigation |
| Fragment transactions | Navigator stack | No backstack bugs |
| SharedPreferences only | SharedPrefs + Hive | Structured local cache |
| Direct Firebase calls in Activities | Repository pattern via Riverpod | Testable, scalable |
| OkHttp for Supabase | Dio | Better interceptors, cleaner |
| Hardcoded Supabase keys | flutter_dotenv / --dart-define | Secure config |
| No error states | Full loading/error/empty states | Production quality |
| No form validation | Reactive form validation | No crashes from bad input |
| Background services (deprecated APIs) | flutter_background_service | Modern, maintained |

---

## START COMMAND (After Flutter SDK Install)

```bash
# 1. Verify Flutter is working
flutter doctor

# 2. Create project next to current repo
cd C:\Users\PRANAV\Documents\GitHub
flutter create --org com.urbaneaze --project-name urbaneaze_flutter flutter_urbaneaze

# 3. Install FlutterFire CLI
dart pub global activate flutterfire_cli

# 4. Configure Firebase (uses existing google-services.json project)
cd flutter_urbaneaze
flutterfire configure

# 5. Open in VS Code
code .
```

---

*This plan is the north star. Every session picks up the next unchecked item.*
*Current Java project stays untouched as reference.*
