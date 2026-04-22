# KukuFiti Mobile - Build Automation Guide

This guide explains how the automated backend URL injection and version management works in the GitHub Actions workflow for the mobile app.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Configuration](#configuration)
- [GitHub Actions Workflow](#github-actions-workflow)
- [Local Development](#local-development)
- [Version Management](#version-management)
- [Troubleshooting](#troubleshooting)

---

## Overview

The build automation system automatically:

1. **Injects Backend URLs** based on the branch (main/develop)
2. **Manages Versions** using semantic versioning + build numbers
3. **Generates Release Information** for Firebase App Distribution and GitHub Releases
4. **Validates Configuration** before building

### Key Features

✅ **Environment-aware URLs** - Different APIs for different branches  
✅ **Automatic Version Bumping** - Uses GitHub Actions run number as build number  
✅ **Flexible Configuration** - Supports `.env` files and GitHub Secrets  
✅ **Build Information Display** - Shows version and API URL in app logs  
✅ **Local Testing Support** - Helper scripts for local builds with different configs  

---

## Architecture

### Configuration Flow

```
┌─────────────────────────────────────────────────────┐
│ GitHub Event (push to main/develop)                 │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│ Workflow: build-and-release.yml                     │
└────────────────────┬────────────────────────────────┘
                     │
         ┌───────────┼───────────┐
         │           │           │
         ▼           ▼           ▼
    backend/.env  .env files  GitHub Secrets
         │           │           │
         └───────────┼───────────┘
                     │
                     ▼
         ┌──────────────────────┐
         │ Prepare Metadata Step │
         │ - Extract Version     │
         │ - Resolve API URL     │
         │ - Set Build Number    │
         └──────────┬───────────┘
                     │
         ┌───────────┴──────────┐
         │                      │
         ▼                      ▼
    Flutter Build          Release Jobs
    --dart-define         - Firebase
    API_URL               - GitHub Release
```

### Data Flow

```
pubspec.yaml (version: 1.2.8+2)
           ↓
   [Extract base version: 1.2.8]
           ↓
   [GitHub Run Number: 42]
           ↓
   [Combine: 1.2.8+42]
           ↓
   Flutter Build Artifacts
```

---

## Configuration

### 1. GitHub Secrets Setup

Configure these secrets in your GitHub repository settings:

| Secret | Description | Example |
|--------|-------------|---------|
| `API_URL` | Default API URL | `https://api.example.com/api/v1` |
| `DEV_API_URL` | Development API (develop branch) | `https://dev-api.example.com/api/v1` |
| `PROD_API_URL` | Production API (main branch) | `https://api.example.com/api/v1` |
| `KEYSTORE_BASE64` | Android keystore encoded in base64 | Generated with `base64 -w 0 keystore.jks` |
| `KEY_STORE_PASSWORD` | Keystore password | `your_keystore_password` |
| `KEY_PASSWORD` | Key password | `your_key_password` |
| `KEY_ALIAS` | Key alias | `kukufiti-key` |
| `GOOGLE_SERVICES_JSON` | Firebase google-services.json encoded | Generated with `base64 -w 0 google-services.json` |
| `FIREBASE_APP_ID` | Firebase App ID | `1:234567890:android:abcdef1234567890` |
| `FIREBASE_SERVICE_ACCOUNT` | Firebase service account JSON | Full JSON encoded in base64 |

### 2. Backend `.env` File (Priority #1)

Create `backend/.env` with these variables:

```env
# API URLs for mobile app
MOBILE_API_URL=https://api.example.com/api/v1
MOBILE_API_URL_DEV=https://dev-api.example.com/api/v1
MOBILE_API_URL_PROD=https://api.example.com/api/v1
```

**Priority Order:**
1. Branch-specific `.env` values (`MOBILE_API_URL_DEV` for develop branch)
2. Generic `.env` value (`MOBILE_API_URL`)
3. Branch-specific GitHub Secret (`DEV_API_URL` for develop)
4. Default GitHub Secret (`API_URL`)

### 3. Version Management in `pubspec.yaml`

```yaml
version: 1.2.8+2
```

- **1.2.8** = Semantic version (major.minor.patch)
- **+2** = Build number (auto-replaced by GitHub Actions)

---

## GitHub Actions Workflow

### Triggered On

- Push to `main` branch
- Push to `develop` branch
- Pull requests (if configured)

### Key Steps

#### Step 9: Prepare Build Metadata

Extracts and validates:
- Version from `pubspec.yaml`
- Build number from `GITHUB_RUN_NUMBER`
- API URL from configured sources
- Release tag in format: `v1.2.8-develop.42`

Output:
```
api_url=https://api.example.com/api/v1
build_name=1.2.8
build_number=42
release_version=1.2.8+42
release_tag=v1.2.8-develop.42
```

#### Step 10: Build Release APK

```bash
flutter build apk --release \
  --dart-define=API_URL=https://api.example.com/api/v1 \
  --build-name=1.2.8 \
  --build-number=42
```

The `--dart-define=API_URL` injects the API URL into the app via `String.fromEnvironment()`.

#### Step 13: Firebase App Distribution

Uploads APK to Firebase with:
- Release notes including build number and commit
- API URL in release notes
- Group: `internal-testers`

#### Step 14: GitHub Release

Creates a GitHub release with:
- Version tag: `v1.2.8-develop.42`
- Release notes with build info
- APK artifact attached
- Installation instructions

#### Step 15: Cleanup Old Releases

On develop branch: Keeps only 3 latest pre-releases, deletes older ones.

---

## Local Development

### Option 1: Using Helper Script

```bash
# Generate configuration for development environment
./scripts/generate_build_config.sh --env dev

# Output includes:
# - Configuration summary
# - Generated Dart defines
# - Next steps for building
```

### Option 2: Manual Build with Custom API URL

```bash
# Build with custom API URL
flutter build apk --release \
  --dart-define=API_URL=http://192.168.1.100:8080/api/v1 \
  --build-name=1.2.8 \
  --build-number=1
```

### Option 3: Run with Custom API URL

```bash
# Run in debug mode with custom API URL
flutter run \
  --dart-define=API_URL=http://localhost:8080/api/v1
```

### Available Script Options

```bash
# Show help
./scripts/generate_build_config.sh --help

# Generate dev config
./scripts/generate_build_config.sh --env dev

# Generate prod config
./scripts/generate_build_config.sh --env prod

# Generate local config
./scripts/generate_build_config.sh --env local

# Custom API URL
./scripts/generate_build_config.sh --env dev --api-url http://192.168.1.50:8080/api/v1

# Custom version
./scripts/generate_build_config.sh --version 2.0.0 --build-number 100
```

---

## Version Management

### Automatic Version Bumping

Use the Python script to bump versions:

```bash
# Bump patch version (1.2.8 → 1.2.9)
python3 scripts/bump_version.py --bump patch

# Bump minor version (1.2.8 → 1.3.0)
python3 scripts/bump_version.py --bump minor

# Bump major version (1.2.8 → 2.0.0)
python3 scripts/bump_version.py --bump major

# Set specific build number
python3 scripts/bump_version.py --build-number 50
```

### Output

```
════════════════════════════════════════════════════════
  Version Bump Summary
════════════════════════════════════════════════════════
  File: pubspec.yaml
  Timestamp: 2024-04-22 14:30:45

  Old Version: 1.2.8+2
  New Version: 1.2.9+3

  Version Change: 1.2.8 → 1.2.9
  Build Number: 2 → 3
════════════════════════════════════════════════════════
```

### Version Format

```
X.Y.Z+N

X = Major version (breaking changes)
Y = Minor version (new features)
Z = Patch version (bug fixes)
N = Build number (auto-incremented by GitHub Actions)
```

Examples:
- `1.0.0+1` - Initial release, build 1
- `1.0.1+5` - Patch release, build 5
- `1.1.0+12` - Minor release, build 12
- `2.0.0+1` - Major release, build 1

---

## Build Information in App

### Display Build Info

In your app code:

```dart
import 'package:mobile/core/config/app_config.dart';

// Print build information
AppConfig.printBuildInfo();

// Access individual values
print('Version: ${AppConfig.appVersion}');
print('Build: ${AppConfig.buildNumber}');
print('Full: ${AppConfig.fullVersion}');
print('API: ${AppConfig.apiUrl}');
print('Mode: ${AppConfig.buildMode}');
```

### Example Output

```
╔════════════════════════════════════════════════════════╗
║         KukuFiti - Build Information                  ║
╠════════════════════════════════════════════════════════╣
║ App:              KukuFiti                             ║
║ Version:          1.2.8                               ║
║ Build Number:     42                                  ║
║ Full Version:     1.2.8+42                            ║
║ Build Mode:       release                             ║
║ Platform:         Android                             ║
║ API URL:          api.example.com                     ║
║ Package:          com.example.kukufiti                ║
╚════════════════════════════════════════════════════════╝
```

### Runtime API URL Change

```dart
// Change API URL at runtime (persisted to local storage)
await AppConfig.setApiUrl('http://192.168.1.50:8080/api/v1');

// Reset to default
await AppConfig.resetApiUrl();
```

---

## Environment Variables

### Available Dart Defines

Currently injected during build:

| Variable | Source | Used For |
|----------|--------|----------|
| `API_URL` | GitHub Actions metadata step | Backend API endpoint |

### Adding New Variables

To add more variables:

1. Update workflow to extract variable:
   ```bash
   echo "my_var=${MY_VAR}" >> "$GITHUB_OUTPUT"
   ```

2. Pass to Flutter build:
   ```bash
   flutter build apk --release \
     --dart-define=MY_VAR=${{ steps.metadata.outputs.my_var }}
   ```

3. Access in app:
   ```dart
   const myVar = String.fromEnvironment('MY_VAR', defaultValue: 'default');
   ```

---

## Troubleshooting

### Issue: "API URL is empty"

**Solution:**
1. Check GitHub Secrets are configured
2. Or ensure `backend/.env` exists with `MOBILE_API_URL` variables
3. Or set `API_URL` secret as fallback

### Issue: Wrong API URL in build

**Cause:** Priority order not followed

**Solution:** Check priority order:
1. Branch-specific `.env` (highest priority)
2. Generic `.env`
3. Branch-specific GitHub Secret
4. Default GitHub Secret (lowest priority)

### Issue: Version not updating

**Cause:** Using hardcoded build number

**Solution:** Don't hardcode build number, let GitHub Actions use `GITHUB_RUN_NUMBER`

### Issue: App shows old version

**Cause:** Building locally without updating pubspec.yaml

**Solution:** Update `pubspec.yaml` version before building:
```bash
python3 scripts/bump_version.py --bump patch
```

### Issue: Workflow fails during build

**Steps to debug:**

1. Check workflow logs on GitHub Actions
2. Look for "Prepare build metadata" step output
3. Verify all required secrets are set
4. Test locally:
   ```bash
   ./scripts/generate_build_config.sh --env dev
   ```

### View Build Logs

1. Go to GitHub repo → Actions tab
2. Click on failed workflow run
3. Expand "Build & Release Flutter APK" job
4. Look at "Prepare build metadata" step for configuration
5. Check "Build release APK" step for actual errors

---

## Advanced: Adding Custom Configuration

### Example: API Key Injection

1. Add secret to GitHub: `API_KEY=your_secret_key`

2. Update workflow step:
   ```yaml
   - name: Prepare build metadata
     env:
       API_KEY: ${{ secrets.API_KEY }}
     run: |
       # ... existing code ...
       echo "api_key=${API_KEY}" >> "$GITHUB_OUTPUT"
   ```

3. Update build step:
   ```bash
   flutter build apk --release \
     --dart-define=API_URL=${{ steps.metadata.outputs.api_url }} \
     --dart-define=API_KEY=${{ steps.metadata.outputs.api_key }}
   ```

4. Access in app:
   ```dart
   const apiKey = String.fromEnvironment('API_KEY', defaultValue: '');
   ```

---

## Related Documentation

- [Flutter Build Definition](https://flutter.dev/docs/deployment/android)
- [GitHub Actions Workflows](https://docs.github.com/en/actions/using-workflows)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [AppConfig Class](../lib/core/config/app_config.dart)

---

## Quick Reference

### Common Commands

```bash
# View current configuration
cat .build_config.env

# Generate development build config
./scripts/generate_build_config.sh --env dev

# Bump version before release
python3 scripts/bump_version.py --bump minor

# Check current version
grep '^version:' pubspec.yaml

# Build locally with custom URL
flutter build apk --release \
  --dart-define=API_URL=http://192.168.1.100:8080/api/v1
```

### GitHub Secrets Checklist

- [ ] `API_URL` (default fallback)
- [ ] `DEV_API_URL` (develop branch)
- [ ] `PROD_API_URL` (main branch)
- [ ] `KEYSTORE_BASE64`
- [ ] `KEY_STORE_PASSWORD`
- [ ] `KEY_PASSWORD`
- [ ] `KEY_ALIAS`
- [ ] `GOOGLE_SERVICES_JSON`
- [ ] `FIREBASE_APP_ID`
- [ ] `FIREBASE_SERVICE_ACCOUNT`

---

**Last Updated:** April 22, 2024  
**Maintained By:** Development Team  
**Status:** Active
