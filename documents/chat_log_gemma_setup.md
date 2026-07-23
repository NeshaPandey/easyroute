# 📄 Google Gemma Setup Chat Log & Summary

**Date**: 2026-06-20
**Project**: EasyRoute (Flutter Mobile App)
**Topic**: Migrating AI Navigation Service to Google Gemma and resolving Android Build issues.

---

## 1. Google Gemma configuration details

### Environment Configuration (`.env` in root)
Add your Gemma/Gemini API key:
```env
GEMINI_API_KEY = AQ.Ab8RN6KiZmu9w6VR3Z7FSisLqRVCnFq77CLVnlWj4u23682dSQ
```

### Run Command
Since Dart reads parameters at compilation/run time via `--dart-define`, launch the application with:
```bash
flutter run --dart-define=GEMINI_API_KEY=AQ.Ab8RN6KiZmu9w6VR3Z7FSisLqRVCnFq77CLVnlWj4u23682dSQ
```

---

## 2. Code Changes Made

### `lib/core/utils/ai_navigation_service.dart`
Migrated the service from Anthropic (Claude) to Google Gemma:
* **API Key Retrieval**: Reads `GEMINI_API_KEY` from environment variables.
* **HTTP POST**: Replaced the Anthropic Messages endpoint with the Google Generative Language API endpoint:
  ```
  https://generativelanguage.googleapis.com/v1beta/models/gemma-3-27b-it:generateContent?key=$geminiKey
  ```
* **Payload Structure**: Adapted request body schema for the Gemma model.
* **Response Parsing**: Changed response reader from Anthropic format (`data['content'][0]['text']`) to Google format (`data['candidates'][0]['content']['parts'][0]['text']`).

---

## 3. Resolving the Android Build Error

### The Problem
* Error: `Build failed due to use of deleted Android v1 embedding.`
* Cause: The project's `android` platform folder was missing the required Gradle and Activity templates to support v2 embedding.

### The Solution
1. **Recreated Platform Templates**:
   ```bash
   flutter create --platforms=android .
   ```
2. **Fixed Package Namespace & Name**:
   * Restructured the native entry activity location to `android/app/src/main/kotlin/com/easyroute/app/MainActivity.kt`.
   * Updated `namespace` and `applicationId` inside `android/app/build.gradle.kts` to `com.easyroute.app` to match the configuration in `android/app/google-services.json`.
