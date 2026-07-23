# 🗺️ EasyRoute – Project Tracker

> Last Updated: 2026-06-15 | AI: Google Gemma (pending migration) | Map: Mapbox (pending migration)

---

## 📊 Overall Progress

| Area | Status | Completion |
|---|---|---|
| Core Architecture | ✅ Done | 100% |
| Design System & Theme | ✅ Done | 100% |
| Routing & Navigation Config | ✅ Done | 100% |
| Domain Layer (Entities) | ✅ Done | 100% |
| State Management (BLoC) | ✅ Done | 100% |
| Auth Screens | ✅ Done | 100% |
| Home Screen | ✅ Done | 100% |
| Route Search & Selection | ✅ Done | 100% |
| Navigation Screen | ✅ Done | 100% |
| Profile Screen | ✅ Done | 100% |
| Emergency / SOS Screen | ✅ Done | 100% |
| Shared Widgets | ✅ Done | 100% |
| AI Service (Anthropic → Gemma) | ⚠️ Needs Migration | 50% |
| Maps Integration (Google → Mapbox) | ⚠️ Needs Migration | 30% |
| Firebase Integration | ⚠️ Config Missing | 20% |
| Backend / Repository Layer | ❌ Not Started | 0% |
| Assets (fonts / icons / images) | ❌ Missing | 0% |
| Backend Node.js API | ❌ Not Started | 0% |
| Tests | ❌ Not Started | 0% |
| Security Hardening | ❌ Not Started | 0% |

---

## ✅ COMPLETED

### 1. Core Architecture & Foundation

| File | Status | Notes |
|---|---|---|
| `lib/main.dart` | ✅ Done | Entry point, Firebase init, BLoC providers, theme toggle |
| `lib/core/constants/app_constants.dart` | ✅ Done | App-wide constants, route names, deviation threshold |
| `lib/core/theme/app_theme.dart` | ✅ Done | Full light + dark Material 3 design system (Inter font) |
| `lib/core/router/app_router.dart` | ✅ Done | GoRouter configuration with all named routes |

### 2. Domain Layer

| File | Status | Notes |
|---|---|---|
| `lib/domain/entities/route_entity.dart` | ✅ Done | All core entities: RouteEntity, RouteLegEntity, RouteStepEntity, PlaceEntity, UserEntity, LatLngEntity, UserPreferences |

### 3. State Management (BLoC)

| File | Status | Notes |
|---|---|---|
| `lib/presentation/bloc/auth/auth_bloc.dart` | ✅ Done | Email + Google auth events/states, demo mode fallback |
| `lib/presentation/bloc/route/route_bloc.dart` | ✅ Done | Route search, selection, 4 route types; mock data included |
| `lib/presentation/bloc/navigation/navigation_bloc.dart` | ✅ Done | Full turn-by-turn tracking, deviation detection, step advancement, voice toggle |
| `lib/presentation/bloc/location/location_bloc.dart` | ✅ Done | GPS location BLoC skeleton |

### 4. Screens (UI)

| File | Status | Notes |
|---|---|---|
| `lib/presentation/screens/auth/splash_screen.dart` | ✅ Done | Animated splash with auth check |
| `lib/presentation/screens/auth/login_screen.dart` | ✅ Done | Email + Google sign-in UI |
| `lib/presentation/screens/auth/signup_screen.dart` | ✅ Done | Email sign-up form |
| `lib/presentation/screens/home/home_screen.dart` | ✅ Done | Search bar, recent places, favourites, voice FAB |
| `lib/presentation/screens/route/search_screen.dart` | ✅ Done | Origin/destination search, Places integration |
| `lib/presentation/screens/route/route_selection_screen.dart` | ✅ Done | 4 route type cards (Fastest/Cheapest/Least Walking/Transit) |
| `lib/presentation/screens/navigation/navigation_screen.dart` | ✅ Done | Turn-by-turn map view, voice guidance, step panel |
| `lib/presentation/screens/profile/profile_screen.dart` | ✅ Done | User info, preferences, accessibility settings |
| `lib/presentation/screens/emergency/emergency_screen.dart` | ✅ Done | SOS button, emergency contacts, location sharing |

### 5. Shared Widgets

| File | Status | Notes |
|---|---|---|
| `lib/presentation/widgets/common/er_button.dart` | ✅ Done | Primary branded button |
| `lib/presentation/widgets/common/er_text_field.dart` | ✅ Done | Styled text input |
| `lib/presentation/widgets/common/voice_fab.dart` | ✅ Done | Voice input floating action button |
| `lib/presentation/widgets/home/place_chip.dart` | ✅ Done | Favourite place chip |
| `lib/presentation/widgets/home/recent_place_tile.dart` | ✅ Done | Recent search list tile |
| `lib/presentation/widgets/route/route_card.dart` | ✅ Done | Route option card with cost/time/walk distance |
| `lib/presentation/widgets/route/route_summary_bar.dart` | ✅ Done | Bottom bar during navigation showing ETA |

### 6. AI Navigation Service (Partial)

| File | Status | Notes |
|---|---|---|
| `lib/core/utils/ai_navigation_service.dart` | ⚠️ Partial | Service is fully built but wired to **Anthropic Claude**. Must be migrated to **Google Gemma**. Fallback (rule-based) logic is complete. |

---

## ⚠️ IN PROGRESS / PARTIAL

### 7. AI Integration — Needs Migration: Anthropic → Google Gemma

- **Current state**: `ai_navigation_service.dart` calls `https://api.anthropic.com/v1/messages` with model `claude-sonnet-4-20250514`
- **Required**: Migrate API calls to Google Gemma (via Google AI Studio / Vertex AI)
- **Tasks remaining**:
  - [ ] Replace HTTP endpoint with Gemma API endpoint
  - [ ] Update request/response payload format for Gemma
  - [ ] Update `ANTHROPIC_API_KEY` env variable to `GEMINI_API_KEY`
  - [ ] Update model name to `gemma-3-27b-it` or equivalent
  - [ ] Test fallback behavior remains intact
  - [ ] Update README and `.env` docs

### 8. Maps Integration — Needs Migration: Google Maps → Mapbox

- **Current state**: `pubspec.yaml` uses `google_maps_flutter: ^2.5.3` and `flutter_polyline_points: ^2.0.0`
- **Required**: Replace with Mapbox Flutter SDK
- **Tasks remaining**:
  - [ ] Remove `google_maps_flutter` and `flutter_polyline_points` from `pubspec.yaml`
  - [ ] Add `mapbox_maps_flutter` to `pubspec.yaml`
  - [ ] Update `navigation_screen.dart` — replace `GoogleMap` widget with `MapboxMap`
  - [ ] Update `AndroidManifest.xml` — add Mapbox token (instead of Google Maps API key)
  - [ ] Update `Info.plist` (iOS) — add Mapbox access token
  - [ ] Replace Google Directions API calls in `route_bloc.dart` with Mapbox Directions API
  - [ ] Replace Places API calls in `search_screen.dart` with Mapbox Search / Geocoding API
  - [ ] Update environment variables (`GOOGLE_MAPS_API_KEY` → `MAPBOX_ACCESS_TOKEN`)

---

## ❌ NOT STARTED

### 9. Firebase Configuration (Critical — App won't work without this)

- [ ] Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- [ ] Download `google-services.json` → place in `android/app/`
- [ ] Download `GoogleService-Info.plist` → place in `ios/Runner/`
- [ ] Enable Authentication: Email/Password + Google Sign-In
- [ ] Enable Firestore Database
- [ ] Set Firestore security rules
- [ ] Replace demo/mock auth in `auth_bloc.dart` with real `FirebaseAuth` calls

### 10. Repository Layer (Data Layer — Currently Missing)

The BLoC layer currently uses hardcoded mock data. A proper repository layer needs to be built:

- [ ] `lib/data/repositories/route_repository.dart` — Mapbox Directions API calls
- [ ] `lib/data/repositories/auth_repository.dart` — Firebase Auth wrapper
- [ ] `lib/data/repositories/user_repository.dart` — Firestore user data
- [ ] `lib/data/repositories/place_repository.dart` — Mapbox Geocoding/Search
- [ ] `lib/data/repositories/transit_repository.dart` — Real-time transit arrivals
- [ ] Wire repositories into BLoCs via `get_it` dependency injection

### 11. Assets (Currently Missing — App will crash)

> ⚠️ `pubspec.yaml` declares assets but the directories don't exist

- [ ] Create `assets/images/` directory and add placeholder/logo images
- [ ] Create `assets/icons/` directory and add SVG icons
- [ ] Add Inter font files to `assets/fonts/`:
  - [ ] `Inter-Regular.ttf`
  - [ ] `Inter-Medium.ttf`
  - [ ] `Inter-SemiBold.ttf`
  - [ ] `Inter-Bold.ttf`
- [ ] Add Lottie animation files (referenced by `lottie` package)

### 12. Backend API (Optional — Node.js/Express)

From the README, a backend API was designed but not implemented:

- [ ] `POST /api/routes/search` — Route search endpoint
- [ ] `GET /api/routes/:id` — Route retrieval
- [ ] `POST /api/ai/transform-step` — Server-side Gemma AI call (secure)
- [ ] `GET /api/transit/arrivals` — Real-time transit data
- [ ] `POST /api/emergency/sos` — SOS notification endpoint
- [ ] Move AI API key server-side (security requirement)

### 13. Testing

- [ ] Unit tests for BLoC logic (`flutter_test` + `mockito` — already in dev deps)
- [ ] Unit tests for `AiNavigationService`
- [ ] Widget tests for screens
- [ ] Integration tests for navigation flow

### 14. Security Hardening

- [ ] Never commit API keys — enforce via `.gitignore`
- [ ] Set Firebase security rules (restrict to authenticated users)
- [ ] Restrict Mapbox token to app bundle ID
- [ ] Move Gemma API key to server-side backend (not in app binary)
- [ ] Encrypt emergency contact data at rest

---

## 🐛 Known Issues

| Issue | Severity | Location |
|---|---|---|
| `assets/` directories don't exist — app will crash on startup | 🔴 Critical | `pubspec.yaml` |
| `google-services.json` missing — Firebase init silently fails | 🔴 Critical | `android/app/` |
| `GoogleService-Info.plist` missing — Firebase init silently fails | 🔴 Critical | `ios/Runner/` |
| AI service calls Anthropic — needs Gemma migration | 🟠 High | `ai_navigation_service.dart` |
| Maps uses Google Maps Flutter SDK — needs Mapbox migration | 🟠 High | `navigation_screen.dart`, `pubspec.yaml` |
| Auth BLoC uses demo/mock data — not production-ready | 🟡 Medium | `auth_bloc.dart` |
| Route BLoC generates mock routes — not real Directions API | 🟡 Medium | `route_bloc.dart` |
| No backend repository layer — all data is hardcoded | 🟡 Medium | Entire data layer |
| Inter font files missing — app may use system fallback | 🟡 Medium | `assets/fonts/` |
| `{lib` directory in root (stray directory name) | 🟢 Low | Project root |

---

## 📁 Project File Inventory

```
easyroute/
├── lib/                         ✅ 26 dart files
│   ├── main.dart                ✅
│   ├── core/
│   │   ├── constants/           ✅ app_constants.dart
│   │   ├── theme/               ✅ app_theme.dart
│   │   ├── router/              ✅ app_router.dart
│   │   └── utils/               ✅ ai_navigation_service.dart
│   ├── domain/
│   │   └── entities/            ✅ route_entity.dart
│   └── presentation/
│       ├── bloc/                ✅ auth, route, navigation, location
│       ├── screens/             ✅ auth(3), home, route(2), navigation, profile, emergency
│       └── widgets/             ✅ common(3), home(2), route(2)
├── android/                     ✅ AndroidManifest.xml present
├── ios/                         ✅ Directory present (not fully scanned)
├── pubspec.yaml                 ✅
├── README.md                    ✅
├── assets/                      ❌ MISSING — must create
│   ├── fonts/                   ❌ MISSING
│   ├── images/                  ❌ MISSING
│   └── icons/                   ❌ MISSING
├── android/app/google-services.json  ❌ MISSING
└── ios/Runner/GoogleService-Info.plist ❌ MISSING
```

---

## 🎯 Priority Order for Next Steps

1. 🔴 **Create `assets/` directories** and add font files (app crashes without these)
2. 🔴 **Firebase setup** — download and place config files
3. 🟠 **Migrate AI to Google Gemma** (see `dependencies_setup.md`)
4. 🟠 **Migrate Maps to Mapbox** (see `dependencies_setup.md`)
5. 🟡 **Build Repository layer** — connect BLoCs to real APIs
6. 🟡 **Wire real Firebase Auth** — replace mock auth in `auth_bloc.dart`
7. 🟢 **Write tests** — use existing `mockito` + `flutter_test` dev deps
8. 🟢 **Build backend API** — secure the Gemma API key server-side
