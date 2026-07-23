# 🗺️ EasyRoute – AI Smart Navigation Assistant

> Navigate with confidence. Simple, human-friendly directions for everyone.

EasyRoute replaces confusing map interfaces with warm, conversational turn-by-turn guidance — using landmarks, plain language, and AI to make navigation accessible to all.

---

## ✨ Features

| Feature | Status |
|---|---|
| Email & Google Authentication | ✅ |
| Home screen with search & favourites | ✅ |
| Voice search (Speech-to-Text) | ✅ |
| GPS-based current location | ✅ |
| 4 route options (Fastest / Cheapest / Least Walking / Transit) | ✅ |
| AI-powered natural language directions | ✅ |
| Turn-by-turn navigation with Google Maps | ✅ |
| Real-time route deviation detection | ✅ |
| Text-to-Speech voice guidance | ✅ |
| Emergency SOS with contact sharing | ✅ |
| Dark mode support | ✅ |
| Accessibility: high contrast, text scale | ✅ |

---

## 🏗️ Architecture

```
easyroute/
├── lib/
│   ├── main.dart                        # Entry point
│   ├── core/
│   │   ├── constants/app_constants.dart  # App-wide constants & route names
│   │   ├── theme/app_theme.dart          # Design system (colors, typography)
│   │   ├── router/app_router.dart        # go_router configuration
│   │   └── utils/
│   │       └── ai_navigation_service.dart # Claude AI instruction transformer
│   ├── domain/
│   │   └── entities/route_entity.dart    # Pure Dart domain models
│   └── presentation/
│       ├── bloc/
│       │   ├── auth/auth_bloc.dart
│       │   ├── route/route_bloc.dart
│       │   ├── navigation/navigation_bloc.dart
│       │   └── location/location_bloc.dart
│       ├── screens/
│       │   ├── auth/   (splash, login, signup)
│       │   ├── home/   (home_screen)
│       │   ├── route/  (search, route_selection)
│       │   ├── navigation/ (navigation_screen)
│       │   ├── profile/
│       │   └── emergency/
│       └── widgets/
│           ├── common/ (er_button, er_text_field, voice_fab)
│           ├── home/   (place_chip, recent_place_tile)
│           └── route/  (route_card, route_summary_bar)
```

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK ≥ 3.1.0 (run `flutter --version`)
- Android Studio or Xcode
- A Google Cloud account (for Maps & Places APIs)
- Firebase project (for Auth & Firestore)
- Anthropic API key (for AI directions)

---

### Step 1 — Clone & Install

```bash
git clone https://github.com/yourname/easyroute.git
cd easyroute
flutter pub get
```

---

### Step 2 — Google Maps API

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Directions API
   - Places API
   - Geocoding API
3. Create an API key and restrict it to your app's bundle ID / SHA-1
4. Add to your environment (see Step 5)

---

### Step 3 — Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add an Android app with your package name (`com.easyroute.app`)
3. Add an iOS app with your bundle ID
4. Download `google-services.json` → place in `android/app/`
5. Download `GoogleService-Info.plist` → place in `ios/Runner/`
6. Enable **Authentication** → Email/Password + Google Sign-In
7. Enable **Firestore Database**

---

### Step 4 — Anthropic API Key

Get your key from [console.anthropic.com](https://console.anthropic.com).

The AI Navigation Service (`lib/core/utils/ai_navigation_service.dart`) uses it to transform raw directions into human-friendly language.

---

### Step 5 — Environment Variables

Create a `.env` file in the project root (never commit this):

```
GOOGLE_MAPS_API_KEY=AIzaSy...
ANTHROPIC_API_KEY=sk-ant-...
```

Then pass them at build time:

```bash
# Android debug
flutter run \
  --dart-define=GOOGLE_MAPS_API_KEY=AIzaSy... \
  --dart-define=ANTHROPIC_API_KEY=sk-ant-...

# iOS
flutter run \
  --dart-define=GOOGLE_MAPS_API_KEY=AIzaSy... \
  --dart-define=ANTHROPIC_API_KEY=sk-ant-...
```

Or add a `launch.json` in VS Code:
```json
{
  "configurations": [{
    "name": "EasyRoute",
    "request": "launch",
    "type": "dart",
    "args": [
      "--dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY",
      "--dart-define=ANTHROPIC_API_KEY=YOUR_KEY"
    ]
  }]
}
```

---

### Step 6 — Android Configuration

In `android/app/build.gradle`, update:
```gradle
android {
    defaultConfig {
        applicationId "com.easyroute.app"
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

The `AndroidManifest.xml` is already configured with all required permissions.

---

### Step 7 — iOS Configuration

```bash
cd ios
pod install
cd ..
```

The `Info.plist` is already configured with location and microphone permission descriptions.

In Xcode, set your Team and Bundle Identifier under Signing & Capabilities.

---

### Step 8 — Run

```bash
# Check everything
flutter doctor

# Run on connected device or emulator
flutter run

# Build release APK
flutter build apk --release \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY \
  --dart-define=ANTHROPIC_API_KEY=YOUR_KEY

# Build iOS IPA
flutter build ipa --release \
  --dart-define=GOOGLE_MAPS_API_KEY=YOUR_KEY \
  --dart-define=ANTHROPIC_API_KEY=YOUR_KEY
```

---

## 🤖 How the AI Works

`AiNavigationService` sends raw Google Maps step data to Claude (claude-sonnet-4) with a carefully engineered system prompt. The AI:

- Replaces compass directions (N/NW/SE) with landmark references
- Converts distances to time estimates ("about 3 minutes")
- Adds context for turns ("turn right at the traffic light")
- Provides detailed bus/metro boarding instructions
- Counts stops aloud ("stay on for 3 stops")
- Maintains an encouraging, calm tone

Falls back to rule-based transformation when offline.

---

## 🗄️ Database Schema (Firestore)

```
users/{userId}
  - displayName: string
  - email: string
  - photoUrl: string?
  - createdAt: timestamp
  - preferences: {
      voiceGuidanceEnabled: bool
      highContrastMode: bool
      textScale: float
      preferredTransport: string
    }
  - favorites: PlaceEntity[]
  - recentSearches: PlaceEntity[]
  - emergencyContacts: Contact[]

routes/{routeId}           (cached routes)
  - userId: string
  - origin: PlaceEntity
  - destination: PlaceEntity
  - routeData: RouteEntity
  - createdAt: timestamp
```

---

## 🛠️ Backend API Design

If you add a Node.js/Express backend, these are the core endpoints:

```
POST /api/routes/search
  body: { originLat, originLng, destLat, destLng, modes[] }
  → RouteEntity[]

GET  /api/routes/:id
  → RouteEntity

POST /api/ai/transform-step
  body: { rawInstruction, distance, duration, context }
  → { friendlyInstruction }

GET  /api/transit/arrivals
  query: { stopId, line }
  → { arrivals: { line, minutes }[] }

POST /api/emergency/sos
  body: { userId, lat, lng, contacts[] }
  → { sent: true }
```

---

## ♿ Accessibility Notes

- All tap targets are ≥ 44×44px
- Text uses Inter, a highly legible humanist sans-serif
- Colours pass WCAG AA contrast (primary teal on white: 4.8:1)
- High contrast mode increases ratios further
- Voice-first: every action is reachable by voice command
- Navigation relies on landmarks, not compass directions

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management |
| `go_router` | Declarative navigation |
| `google_maps_flutter` | Map rendering |
| `geolocator` | GPS & location |
| `speech_to_text` | Voice input |
| `flutter_tts` | Voice output |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Database |
| `http` | API calls (incl. Claude AI) |

---

## 🔒 Security Checklist

- [ ] API keys stored in environment variables (never committed)
- [ ] Firebase security rules restrict reads/writes to authenticated users
- [ ] Google Maps API key restricted to app bundle ID
- [ ] Anthropic API key only used server-side in production
- [ ] Emergency contact data encrypted at rest

---

## 📄 License

MIT © 2024 EasyRoute
