# Quick Start Guide - Build Automation

Get up and running with automated builds in 5 minutes.

## ⚡ 5-Minute Setup

### 1. Configure GitHub Secrets (2 min)

Go to GitHub Repo → Settings → Secrets and variables → Actions

Add these secrets:

```
API_URL = https://api.example.com/api/v1
DEV_API_URL = https://dev-api.example.com/api/v1
PROD_API_URL = https://api.example.com/api/v1
```

Other secrets (KEYSTORE, FIREBASE, etc.) are already configured.

### 2. Create Backend `.env` (1 min)

Create `backend/.env`:

```env
MOBILE_API_URL=https://api.example.com/api/v1
MOBILE_API_URL_DEV=https://dev-api.example.com/api/v1
MOBILE_API_URL_PROD=https://api.example.com/api/v1
```

### 3. Update Version (1 min)

```bash
python3 mobile/scripts/bump_version.py --bump patch
```

This updates `mobile/pubspec.yaml` version.

### 4. Commit and Push (1 min)

```bash
cd mobile
git add -A
git commit -m "chore: bump version"
git push origin develop  # or main
```

GitHub Actions automatically:
- ✅ Extracts version from pubspec.yaml
- ✅ Resolves API URL based on branch
- ✅ Builds APK with injected config
- ✅ Uploads to Firebase and GitHub Releases

## 🔍 Verify Setup

### Check Current Configuration

```bash
cat mobile/.build_config.env
```

### Generate Local Build Config

```bash
cd mobile
./scripts/generate_build_config.sh --env dev
```

Output:
```
Configuration:
  Environment: dev
  Version:     1.2.8+42
  API URL:     http://localhost:8080/api/v1

Generated Dart Defines:
  --dart-define=API_URL=http://localhost:8080/api/v1
```

### Build Locally

```bash
cd mobile
flutter build apk --release \
  --dart-define=API_URL=http://192.168.1.100:8080/api/v1
```

## 🚀 Common Tasks

### Test with Different API Endpoint

```bash
cd mobile
./scripts/generate_build_config.sh --env dev \
  --api-url http://192.168.1.50:8080/api/v1
```

### Bump Version Before Release

```bash
# Patch version (bug fixes)
python3 mobile/scripts/bump_version.py --bump patch

# Minor version (new features)
python3 mobile/scripts/bump_version.py --bump minor

# Major version (breaking changes)
python3 mobile/scripts/bump_version.py --bump major
```

### View Build Information in App

```dart
import 'package:mobile/core/config/app_config.dart';

// Print build info to console
AppConfig.printBuildInfo();

// Access values
print('${AppConfig.appVersion}+${AppConfig.buildNumber}');
print('API: ${AppConfig.apiUrl}');
```

## ⚙️ Configuration Priority

API URL is resolved in this order (first found wins):

1. **Branch-specific `.env`**
   - `MOBILE_API_URL_DEV` (for develop branch)
   - `MOBILE_API_URL_PROD` (for main branch)

2. **Generic `.env`**
   - `MOBILE_API_URL`

3. **Branch-specific GitHub Secret**
   - `DEV_API_URL` (for develop)
   - `PROD_API_URL` (for main)

4. **Default GitHub Secret**
   - `API_URL`

## 🐛 Troubleshooting

**Q: Build fails with "API URL is empty"**
```
A: Ensure one of these:
   - backend/.env exists with MOBILE_API_URL variables
   - Or GitHub Secrets API_URL / DEV_API_URL / PROD_API_URL are set
```

**Q: How to check GitHub Actions status?**
```
A: Go to GitHub repo → Actions tab
   Click failed run to see detailed logs
```

**Q: How to override API URL locally?**
```
A: ./scripts/generate_build_config.sh --env dev \
     --api-url http://your-ip:8080/api/v1
```

**Q: Version not updating in app?**
```
A: Make sure to rebuild after updating pubspec.yaml
   flutter clean && flutter pub get
```

## 📚 Full Documentation

For complete details, see [BUILD_AUTOMATION.md](BUILD_AUTOMATION.md)

## ✅ Workflow Status

Check GitHub Actions status:

1. Go to: `github.com/YOUR_ORG/broiler-management/actions`
2. Look for "Build & Release APK" workflow
3. Check latest run status

Recent builds automatically:
- Build APK ✅
- Upload to Firebase App Distribution ✅
- Create GitHub Release ✅
- Cleanup old releases (develop branch) ✅

---

**Next Steps:**
1. Set GitHub Secrets (if not done)
2. Create backend/.env
3. Bump version: `python3 mobile/scripts/bump_version.py --bump patch`
4. Push to develop/main branch
5. Watch GitHub Actions build automatically!

For support, check [BUILD_AUTOMATION.md](BUILD_AUTOMATION.md)
