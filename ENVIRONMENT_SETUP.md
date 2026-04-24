# Mobile App - Build Configuration

## Overview

The mobile app does **NOT** use `.env` files. Instead, environment variables are passed via `--dart-define` flags in the build command or GitHub Actions workflow.

## Build Variables

Environment variables are injected at build time using `--dart-define`:

```bash
flutter run \
  --dart-define=API_URL=http://10.0.2.2:8080/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com
```

## Required Variables

### Development (Local Backend)
```bash
flutter run \
  --dart-define=API_URL=http://10.0.2.2:8080/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com
```

### Production
```bash
flutter build apk --release \
  --dart-define=API_URL=https://kukufiti-backend.onrender.com/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com
```

## Build Commands

### Debug APK
```bash
flutter run --dart-define=API_URL=<backend_url> --dart-define=GOOGLE_CLIENT_ID=<client_id>
```

### Release APK
```bash
flutter build apk --release \
  --dart-define=API_URL=https://kukufiti-backend.onrender.com/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com
```

### iOS
```bash
flutter build ios --release \
  --dart-define=API_URL=https://kukufiti-backend.onrender.com/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com
```

## GitHub Actions Workflow

Environment variables are passed from GitHub Secrets:

```yaml
- name: Build Flutter APK
  run: |
    flutter build apk --release \
      --dart-define=API_URL=${{ secrets.API_URL }} \
      --dart-define=GOOGLE_CLIENT_ID=${{ secrets.GOOGLE_CLIENT_ID }}
```

### Required GitHub Secrets
- `GOOGLE_CLIENT_ID` = `227712759483-p0dtbdvjrtji59mhlet9kvprgm552gbh.apps.googleusercontent.com`
- `API_URL` = Backend URL

## Important Notes

- **No `.env` files** — All configuration via `--dart-define` flags or GitHub Actions
- **GOOGLE_CLIENT_ID must be passed** at build time or Google Sign-In will fail
- For Android emulator, use `10.0.2.2` to reference localhost
- For iOS simulator, use `127.0.0.1` or `localhost`

## Troubleshooting

### "GOOGLE_CLIENT_ID is empty"
Ensure `--dart-define=GOOGLE_CLIENT_ID=...` is passed during build or check GitHub Secrets are set correctly

### "Google sign-in failed"
1. Check backend is running and accessible at `API_URL`
2. Verify backend has `GOOGLE_CLIENT_ID` environment variable set (same value)
3. Check device has Google Play Services installed (Android)

