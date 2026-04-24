# Google Sign-In Setup Guide

## Configuration Status ✅

Your Google Sign-In is now configured with:

- **Android Client ID:** `227712759483-gbhfbb76msjhr2snm3v1joo7pii0q20s.apps.googleusercontent.com`
- **Web Client ID (for backend):** `227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com`
- **Android Certificate SHA1:** `6D46A9486E1192EADFAA480C7AE50526CBABDE8A`
- **Package Name:** `com.fredrick.kukufiti`

## Build Commands

### Development/Debug Build

To test Google Sign-In during development:

```bash
cd mobile/

# Debug APK (Android)
flutter run \
  --dart-define=API_URL=http://10.0.2.2:8080/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com

# Or with your actual backend
flutter run \
  --dart-define=API_URL=https://kukufiti-backend.onrender.com/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com
```

### Release APK

```bash
flutter build apk \
  --release \
  --dart-define=API_URL=https://kukufiti-backend.onrender.com/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com
```

### iOS Development

```bash
flutter run \
  --dart-define=API_URL=http://127.0.0.1:8080/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com
```

## Troubleshooting

### "Google Sign-In failed" on Android

1. **Verify `google-services.json`:** The file is at `android/app/google-services.json` with your OAuth client
2. **Check certificate hash:** Run:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
   Verify the SHA1 matches our configuration

3. **Environment variable missing:** Ensure `--dart-define=GOOGLE_CLIENT_ID=...` is passed during build

### "Sign in with Apple" issues on iOS

- Requires a physical device or iOS 13+ simulator
- URL scheme is configured in `ios/Runner/Info.plist`

### Backend 401 Unauthorized

1. Verify the backend `/auth/google` endpoint is accepting the `id_token`
2. Check that `GOOGLE_CLIENT_ID` environment variable is set in your backend

## Files Modified

- ✅ `android/app/google-services.json` — Added Android OAuth client with certificate hash
- ✅ `ios/Runner/Info.plist` — Added URL schemes for OAuth redirect
- ⏭️ Update your CI/CD to pass `--dart-define=GOOGLE_CLIENT_ID=...` during builds

## Environment Setup for CI/CD

If using GitHub Actions or similar CI/CD:

```yaml
- name: Build Release APK
  run: |
    flutter build apk \
      --release \
      --dart-define=API_URL=${{ secrets.API_URL }} \
      --dart-define=GOOGLE_CLIENT_ID=${{ secrets.GOOGLE_CLIENT_ID }}
```

Store `GOOGLE_CLIENT_ID` as a GitHub secret.
