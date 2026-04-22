# Environment Configuration Examples

This file contains example configurations for different deployment environments.

## Development Environment

### File: `backend/.env.development`

```env
# Development API Configuration
MOBILE_API_URL=http://10.0.2.2:8080/api/v1
MOBILE_API_URL_DEV=http://10.0.2.2:8080/api/v1
MOBILE_API_URL_PROD=https://api.example.com/api/v1

# Database
DATABASE_URL=postgresql://dev_user:dev_pass@localhost:5432/kukufiti_dev

# Other configs
DEBUG=True
LOG_LEVEL=DEBUG
```

### File: `backend/.env.local`

```env
# Local Machine API Configuration
MOBILE_API_URL=http://192.168.1.100:8080/api/v1
MOBILE_API_URL_DEV=http://192.168.1.100:8080/api/v1
MOBILE_API_URL_PROD=https://api.example.com/api/v1

# Database
DATABASE_URL=postgresql://dev_user:dev_pass@localhost:5432/kukufiti_local

# Other configs
DEBUG=True
LOG_LEVEL=DEBUG
```

## Staging Environment

### GitHub Secret Configuration

```yaml
# For develop branch deployments
DEV_API_URL: https://staging-api.example.com/api/v1

# For main branch deployments (production)
PROD_API_URL: https://api.example.com/api/v1

# Fallback
API_URL: https://staging-api.example.com/api/v1
```

### File: `backend/.env.staging`

```env
# Staging API Configuration
MOBILE_API_URL=https://staging-api.example.com/api/v1
MOBILE_API_URL_DEV=https://staging-api.example.com/api/v1
MOBILE_API_URL_PROD=https://api.example.com/api/v1

# Database
DATABASE_URL=postgresql://staging_user:staging_pass@staging-db:5432/kukufiti_staging

# Other configs
DEBUG=False
LOG_LEVEL=INFO
SENTRY_DSN=https://your_sentry_dsn@sentry.io/project_id
```

## Production Environment

### GitHub Secret Configuration

```yaml
PROD_API_URL: https://api.example.com/api/v1
API_URL: https://api.example.com/api/v1
```

### File: `backend/.env.production`

```env
# Production API Configuration
MOBILE_API_URL=https://api.example.com/api/v1
MOBILE_API_URL_DEV=https://staging-api.example.com/api/v1
MOBILE_API_URL_PROD=https://api.example.com/api/v1

# Database
DATABASE_URL=postgresql://prod_user:${PROD_DB_PASSWORD}@prod-db:5432/kukufiti_prod

# Other configs
DEBUG=False
LOG_LEVEL=WARNING
SENTRY_DSN=https://your_sentry_dsn@sentry.io/project_id
ANALYTICS_ENABLED=True
```

## Docker Environment Variables

### Docker Compose: `docker-compose.override.yml`

```yaml
version: '3.8'

services:
  backend:
    environment:
      - MOBILE_API_URL=http://localhost:8080/api/v1
      - MOBILE_API_URL_DEV=http://localhost:8080/api/v1
      - MOBILE_API_URL_PROD=https://api.example.com/api/v1
      - DATABASE_URL=postgresql://dev:dev@postgres:5432/kukufiti
      - DEBUG=True
      - LOG_LEVEL=DEBUG
```

## Build Configuration Matrix

### Based on GitHub Actions Branch

| Branch | Env | MOBILE_API_URL_* | Priority | Notes |
|--------|-----|------------------|----------|-------|
| `develop` | dev | DEV env var | 1 | Staging API |
| `develop` | dev | Generic env var | 2 | Fallback |
| `develop` | dev | DEV_API_URL secret | 3 | GitHub Secret |
| `develop` | dev | API_URL secret | 4 | Last resort |
| `main` | prod | PROD env var | 1 | Production API |
| `main` | prod | Generic env var | 2 | Fallback |
| `main` | prod | PROD_API_URL secret | 3 | GitHub Secret |
| `main` | prod | API_URL secret | 4 | Last resort |

## Android Flavor Configuration (Optional)

If you're using Flutter flavors, you can extend the system:

### `pubspec.yaml` Flavors

```yaml
flutter:
  uses-material-design: true
  
  # Define flavors
  flavors:
    development:
      name: KukuFiti Dev
      bundle: com.example.kukufiti.dev
      
    staging:
      name: KukuFiti Staging
      bundle: com.example.kukufiti.staging
      
    production:
      name: KukuFiti
      bundle: com.example.kukufiti
```

### Workflow Extension

```yaml
- name: Build release APK
  run: |
    flavor="prod"
    if [ "${{ github.ref_name }}" = "develop" ]; then
      flavor="staging"
    fi
    
    flutter build apk --release \
      --flavor=$flavor \
      --dart-define=API_URL=${{ steps.metadata.outputs.api_url }}
```

## Local Development Setup

### Using Environment Variables

```bash
# Development with local API
export API_URL=http://10.0.2.2:8080/api/v1
flutter run --dart-define=API_URL=$API_URL

# Or with custom IP
export API_URL=http://192.168.1.50:8080/api/v1
flutter run --dart-define=API_URL=$API_URL
```

### Using Helper Script

```bash
# Generate dev config
./scripts/generate_build_config.sh --env dev

# Generate local config
./scripts/generate_build_config.sh --env local

# Custom IP
./scripts/generate_build_config.sh --env dev \
  --api-url http://192.168.1.50:8080/api/v1

# Build with generated config
source .build_config.env
flutter build apk --release \
  --build-name=$VERSION \
  --build-number=$BUILD_NUMBER \
  $DART_DEFINES
```

## CI/CD Pipeline Configuration

### Pre-build Validation

```bash
#!/bin/bash
# scripts/validate_env.sh

echo "Validating environment configuration..."

# Check pubspec.yaml version format
if ! grep -q 'version: [0-9]*\.[0-9]*\.[0-9]*+[0-9]*' pubspec.yaml; then
  echo "❌ Invalid version format in pubspec.yaml"
  exit 1
fi

# Check API URL configuration
if [ -z "$API_URL" ] && [ -z "$DEV_API_URL" ] && [ -z "$PROD_API_URL" ]; then
  echo "❌ No API URL configured"
  exit 1
fi

echo "✅ Environment validation passed"
```

## Makefile Reference

### `Makefile` for Common Commands

```makefile
.PHONY: build-dev build-prod bump-version show-config

build-dev:
	@./scripts/generate_build_config.sh --env dev
	@flutter build apk --release $(shell cat .build_config.env | grep DART_DEFINES | cut -d= -f2-)

build-prod:
	@./scripts/generate_build_config.sh --env prod
	@flutter build apk --release $(shell cat .build_config.env | grep DART_DEFINES | cut -d= -f2-)

bump-version:
	@python3 scripts/bump_version.py --bump patch

show-config:
	@cat .build_config.env

clean-build:
	@flutter clean
	@rm -f .build_config.env
```

Usage:
```bash
make build-dev      # Build with dev config
make build-prod     # Build with prod config
make bump-version   # Bump patch version
make show-config    # Show current config
make clean-build    # Clean and remove config
```

## API URL Validation

### In Dart Code

```dart
bool isValidApiUrl(String url) {
  try {
    final uri = Uri.parse(url);
    // Validate scheme
    if (!['http', 'https'].contains(uri.scheme)) {
      return false;
    }
    // Validate host
    if (uri.host.isEmpty) {
      return false;
    }
    return true;
  } catch (e) {
    return false;
  }
}
```

### Usage Example

```dart
final apiUrl = AppConfig.apiUrl;
if (!isValidApiUrl(apiUrl)) {
  throw Exception('Invalid API URL: $apiUrl');
}
```

---

## Summary

- **Development**: Use local URLs (10.0.2.2 for emulator, 192.168.x.x for device)
- **Staging**: Use DEV_API_URL secret or `.env` variable
- **Production**: Use PROD_API_URL secret or `.env` variable
- **Fallback**: Use generic API_URL secret

For more details, see [BUILD_AUTOMATION.md](BUILD_AUTOMATION.md)
