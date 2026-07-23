# 🔧 EasyRoute – Dependencies Setup Guide

> This document covers all **external dependencies** for EasyRoute, their current status,
> how to obtain them, and exactly where to place them in the project.

---

## 📋 Dependency Status Overview

| Dependency | Type | Status | Action Required |
|---|---|---|---|
| Google Gemma (AI) | API Key | ❌ Missing | Get from Google AI Studio |
| Mapbox (Maps) | SDK + Token | ❌ Missing | Register & replace Google Maps |
| Firebase (Auth + DB) | Config Files | ❌ Missing | Download from Firebase Console |
| Inter Font Files | Font Assets | ❌ Missing | Download from Google Fonts |
| Lottie Animations | Local Assets | ❌ Missing | Download or create animations |
| `flutter_bloc` | Flutter Package | ✅ In pubspec | Run `flutter pub get` |
| `go_router` | Flutter Package | ✅ In pubspec | Run `flutter pub get` |
| `geolocator` | Flutter Package | ✅ In pubspec | Run `flutter pub get` |
| `speech_to_text` | Flutter Package | ✅ In pubspec | Run `flutter pub get` |
| `flutter_tts` | Flutter Package | ✅ In pubspec | Run `flutter pub get` |

---

## 1. 🤖 Google Gemma AI — **MIGRATION REQUIRED**

> The project currently uses **Anthropic Claude** (`ai_navigation_service.dart`).
> You need to switch to **Google Gemma** as the AI provider.

### Step 1 — Get a Gemini/Gemma API Key

1. Go to **[Google AI Studio](https://aistudio.google.com/app/apikey)**
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Copy the key — it will look like: `AIzaSy...`

> **Tip**: Gemma models are accessed through the same Google Gemini API endpoint.

### Step 2 — Update Environment Variables

Open or create `.env` in the project root:

```
# OLD (remove this):
# ANTHROPIC_API_KEY=sk-ant-...

# NEW — add this:
GEMINI_API_KEY=AIzaSy...
MAPBOX_ACCESS_TOKEN=pk.eyJ1...
```

> ⚠️ **Never commit `.env` to git!** It is already in `.gitignore`.

Update your `launch.json` (VS Code) or run command:

```bash
flutter run \
  --dart-define=GEMINI_API_KEY=AIzaSy... \
  --dart-define=MAPBOX_ACCESS_TOKEN=pk.eyJ1...
```

### Step 3 — Update `ai_navigation_service.dart`

**File location**: `lib/core/utils/ai_navigation_service.dart`

Replace the HTTP call block (around line 84–99) with the Gemma API call:

```dart
// OLD (Anthropic):
final response = await http.post(
  Uri.parse('https://api.anthropic.com/v1/messages'),
  headers: {
    'Content-Type': 'application/json',
    'x-api-key': const String.fromEnvironment('ANTHROPIC_API_KEY'),
    'anthropic-version': '2023-06-01',
  },
  body: jsonEncode({
    'model': 'claude-sonnet-4-20250514',
    'max_tokens': 2000,
    'system': _systemPrompt,
    'messages': [
      {'role': 'user', 'content': userMessage}
    ],
  }),
);

// NEW (Google Gemma via Gemini API):
const geminiKey = String.fromEnvironment('GEMINI_API_KEY');
final response = await http.post(
  Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemma-3-27b-it:generateContent?key=$geminiKey',
  ),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'contents': [
      {
        'parts': [
          {'text': '$_systemPrompt\n\n$userMessage'}
        ]
      }
    ],
    'generationConfig': {
      'maxOutputTokens': 2000,
      'temperature': 0.3,
    },
  }),
);
```

Update the response parsing block:

```dart
// OLD (Anthropic response format):
final data = jsonDecode(response.body);
final text = data['content'][0]['text'] as String;

// NEW (Gemma/Gemini response format):
final data = jsonDecode(response.body);
final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
```

### Available Gemma Models

| Model | Use Case | Notes |
|---|---|---|
| `gemma-3-27b-it` | Best quality | Recommended for production |
| `gemma-3-12b-it` | Balanced | Good trade-off |
| `gemma-3-4b-it` | Fast / Light | Mobile-friendly, reduced cost |

### Step 4 — Update `pubspec.yaml` (No Changes Needed)

The `http` package is already included. No additional packages required for Gemma.

---

## 2. 🗺️ Mapbox — **MIGRATION REQUIRED**

> The project currently uses **`google_maps_flutter`**. You need to switch to the **Mapbox Flutter SDK**.

### Step 1 — Create a Mapbox Account & Get Token

1. Go to **[https://account.mapbox.com/](https://account.mapbox.com/)**
2. Create a free account (50,000 map loads/month free)
3. Go to **Access Tokens** → Click **"Create a token"**
4. Give it a name (e.g., `EasyRoute`)
5. Enable scopes:
   - `styles:read`
   - `tiles:read`
   - `directions:read`
   - `geocoding:read`
6. Copy the **public token** — it starts with `pk.eyJ1...`

### Step 2 — Update `pubspec.yaml`

**File location**: `pubspec.yaml`

```yaml
# REMOVE these:
# google_maps_flutter: ^2.5.3
# flutter_polyline_points: ^2.0.0

# ADD this instead:
dependencies:
  mapbox_maps_flutter: ^2.3.0   # Official Mapbox Flutter SDK
```

Then run:
```bash
flutter pub get
```

### Step 3 — Android Configuration

**File**: `android/app/src/main/AndroidManifest.xml`

Add inside `<application>` tag:
```xml
<!-- REMOVE this Google Maps line if present: -->
<!-- <meta-data android:name="com.google.android.geo.API_KEY"
             android:value="${GOOGLE_MAPS_API_KEY}"/> -->

<!-- ADD Mapbox token: -->
<meta-data
    android:name="MAPBOX_ACCESS_TOKEN"
    android:value="pk.eyJ1..." />
```

**File**: `android/app/build.gradle`

No Mapbox-specific changes needed beyond `minSdkVersion 21` (already set).

### Step 4 — iOS Configuration

**File**: `ios/Runner/Info.plist`

Add inside the root `<dict>`:
```xml
<key>MBXAccessToken</key>
<string>pk.eyJ1...</string>
```

Then run:
```bash
cd ios && pod install && cd ..
```

### Step 5 — Update `navigation_screen.dart`

**File**: `lib/presentation/screens/navigation/navigation_screen.dart`

```dart
// REMOVE:
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// ADD:
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// REPLACE GoogleMap widget with:
MapboxMap(
  mapInitOptions: MapInitOptions(
    styleUri: MapboxStyles.MAPBOX_STREETS,
    cameraOptions: CameraOptions(
      center: Point(coordinates: Position(userLng, userLat)),
      zoom: 15.0,
    ),
  ),
  onMapCreated: (MapboxMap mapboxMap) {
    // Store map controller reference
  },
)
```

### Step 6 — Update Route Search (Mapbox Directions API)

Replace Google Directions API calls in `route_bloc.dart` with Mapbox Directions:

```
GET https://api.mapbox.com/directions/v5/mapbox/driving-traffic/{coordinates}
  ?access_token={MAPBOX_ACCESS_TOKEN}
  &geometries=geojson
  &steps=true
  &voice_instructions=true
```

### Step 7 — Update Places Search (Mapbox Geocoding API)

Replace Google Places API calls in `search_screen.dart` with Mapbox Geocoding:

```
GET https://api.mapbox.com/geocoding/v5/mapbox.places/{search_text}.json
  ?access_token={MAPBOX_ACCESS_TOKEN}
  &country=IN
  &limit=5
```

### Mapbox Free Tier Limits

| Feature | Free Tier |
|---|---|
| Map Loads | 50,000/month |
| Directions API | 100,000 requests/month |
| Geocoding API | 100,000 requests/month |
| Navigation SDK | 25,000 MAU |

---

## 3. 🔥 Firebase — Configuration Files Missing

### Step 1 — Create Firebase Project

1. Go to **[console.firebase.google.com](https://console.firebase.google.com)**
2. Click **"Add project"**
3. Name it `easyroute`
4. Enable Google Analytics (optional)
5. Click **"Create project"**

### Step 2 — Add Android App

1. In Firebase Console → Click **"Add app"** → Android icon
2. Enter package name: **`com.easyroute.app`**
3. Enter app nickname: `EasyRoute Android`
4. (Optional) Enter SHA-1 for Google Sign-In: run `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`
5. Click **"Register app"**
6. Download **`google-services.json`**
7. **Place it at**: `android/app/google-services.json`

### Step 3 — Add iOS App

1. In Firebase Console → Click **"Add app"** → iOS icon
2. Enter bundle ID: **`com.easyroute.app`**
3. Enter app nickname: `EasyRoute iOS`
4. Click **"Register app"**
5. Download **`GoogleService-Info.plist`**
6. **Place it at**: `ios/Runner/GoogleService-Info.plist`

### Step 4 — Enable Authentication

1. Firebase Console → **Authentication** → **Get started**
2. Enable **Email/Password** provider
3. Enable **Google** provider
   - Add your SHA-1 fingerprint for Android
   - Add your bundle ID for iOS

### Step 5 — Enable Firestore

1. Firebase Console → **Firestore Database** → **Create database**
2. Start in **test mode** for development
3. Choose a region (e.g., `asia-south1` for India)

### Step 6 — Set Firestore Security Rules (Production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Routes are user-specific
    match /routes/{routeId} {
      allow read, write: if request.auth != null
        && resource.data.userId == request.auth.uid;
    }
  }
}
```

### File Placement Summary

```
easyroute/
├── android/
│   └── app/
│       └── google-services.json        ← Place here (Step 2)
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist    ← Place here (Step 3)
```

---

## 4. 🔤 Inter Font Files — Missing Assets

> The app declares Inter fonts in `pubspec.yaml` but the files don't exist.
> The app will **fail to load** without them.

### Step 1 — Download Inter Font

1. Go to **[fonts.google.com/specimen/Inter](https://fonts.google.com/specimen/Inter)**
2. Click **"Download family"**
3. Unzip the downloaded file

### Step 2 — Place Font Files

Create directories and copy the files:

```bash
mkdir -p assets/fonts assets/images assets/icons
```

Copy these specific files from the downloaded zip:

| Source File | Destination |
|---|---|
| `Inter-Regular.ttf` (weight 400) | `assets/fonts/Inter-Regular.ttf` |
| `Inter-Medium.ttf` (weight 500) | `assets/fonts/Inter-Medium.ttf` |
| `Inter-SemiBold.ttf` (weight 600) | `assets/fonts/Inter-SemiBold.ttf` |
| `Inter-Bold.ttf` (weight 700) | `assets/fonts/Inter-Bold.ttf` |

### File Placement Summary

```
easyroute/
└── assets/
    ├── fonts/
    │   ├── Inter-Regular.ttf      ← Required
    │   ├── Inter-Medium.ttf       ← Required
    │   ├── Inter-SemiBold.ttf     ← Required
    │   └── Inter-Bold.ttf         ← Required
    ├── images/                    ← Add app images here
    └── icons/                     ← Add SVG icons here
```

---

## 5. ✅ Flutter Packages (Already in `pubspec.yaml`)

These are already declared and will be installed by `flutter pub get`. No action needed beyond that.

```bash
# Install all declared packages:
flutter pub get
```

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^8.1.3 | State management |
| `equatable` | ^2.0.5 | Value equality for BLoC states |
| `provider` | ^6.1.1 | Additional state (if needed) |
| `go_router` | ^12.1.1 | Declarative navigation |
| `firebase_core` | ^2.24.2 | Firebase initialization |
| `firebase_auth` | ^4.15.3 | Authentication |
| `cloud_firestore` | ^4.13.6 | Realtime database |
| `firebase_storage` | ^11.5.6 | File storage |
| `google_sign_in` | ^6.1.6 | Google OAuth |
| `geolocator` | ^10.1.0 | GPS location |
| `geocoding` | ^2.1.1 | Address ↔ coordinates |
| `location` | ^5.0.3 | Background location |
| `http` | ^1.1.0 | HTTP requests (Gemma API) |
| `dio` | ^5.4.0 | Advanced HTTP |
| `speech_to_text` | ^6.6.0 | Voice input |
| `flutter_tts` | ^3.8.5 | Text-to-speech |
| `shared_preferences` | ^2.2.2 | Local key-value storage |
| `hive` | ^2.2.3 | Local database |
| `hive_flutter` | ^1.1.0 | Hive Flutter adapter |
| `path_provider` | ^2.1.1 | File system paths |
| `flutter_svg` | ^2.0.9 | SVG rendering |
| `cached_network_image` | ^3.3.0 | Image caching |
| `shimmer` | ^3.0.0 | Loading skeleton UI |
| `lottie` | ^2.7.0 | Lottie animations |
| `flutter_animate` | ^4.3.0 | Declarative animations |
| `percent_indicator` | ^4.2.3 | Progress bars |
| `sliding_up_panel` | ^2.0.0+1 | Slide-up drawer |
| `smooth_page_indicator` | ^1.1.0 | Page indicators |
| `intl` | ^0.18.1 | Internationalization |
| `url_launcher` | ^6.2.2 | Open URLs/phone calls |
| `permission_handler` | ^11.1.0 | Runtime permissions |
| `connectivity_plus` | ^5.0.2 | Network status |
| `uuid` | ^4.2.2 | Unique ID generation |
| `logger` | ^2.0.2+1 | Logging utility |
| `get_it` | ^7.6.4 | Dependency injection |

---

## 🚀 Quick Start Checklist

Run through these steps in order to get the app running:

```
[ ] 1. flutter pub get
[ ] 2. Create assets/ directories:
        mkdir -p assets/fonts assets/images assets/icons
[ ] 3. Download Inter fonts → place in assets/fonts/
[ ] 4. Get Gemini API key → update .env with GEMINI_API_KEY
[ ] 5. Get Mapbox token → update .env with MAPBOX_ACCESS_TOKEN
[ ] 6. Setup Firebase project → download config files
[ ] 7. Place google-services.json in android/app/
[ ] 8. Place GoogleService-Info.plist in ios/Runner/
[ ] 9. Migrate ai_navigation_service.dart → Gemma API
[  ] 10. Migrate navigation_screen.dart → Mapbox SDK
[ ] 11. cd ios && pod install && cd ..
[ ] 12. flutter run --dart-define=GEMINI_API_KEY=... --dart-define=MAPBOX_ACCESS_TOKEN=...
```

---

## 🔗 Useful Links

| Service | Link |
|---|---|
| Google AI Studio (Gemma/Gemini API) | https://aistudio.google.com/app/apikey |
| Gemma API Docs | https://ai.google.dev/gemma/docs/get_started |
| Gemini API Reference | https://ai.google.dev/api/generate-content |
| Mapbox Account | https://account.mapbox.com |
| Mapbox Flutter SDK | https://pub.dev/packages/mapbox_maps_flutter |
| Mapbox Directions API | https://docs.mapbox.com/api/navigation/directions/ |
| Mapbox Geocoding API | https://docs.mapbox.com/api/search/geocoding/ |
| Firebase Console | https://console.firebase.google.com |
| Firebase Flutter Setup | https://firebase.google.com/docs/flutter/setup |
| Inter Font | https://fonts.google.com/specimen/Inter |
| Flutter Pub Get | https://docs.flutter.dev/packages-and-plugins/using-packages |
