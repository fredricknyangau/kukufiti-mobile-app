# KukuFiti Mobile

> **Flutter 3 · Riverpod · go_router · Dio · Hive**

KukuFiti is a production-grade broiler farm management app for East African poultry farmers. It covers the full cycle from chick placement to harvest — daily operations, health monitoring, financial tracking, AI advisory, and community discussion.

---

## Quick Start

### Prerequisites

| Requirement | Version |
|-------------|---------|
| Flutter SDK | `^3.11.1` |
| Dart SDK | bundled with Flutter |
| Android SDK | API 21+ |
| iOS Deployment Target | 13.0+ |

### Install dependencies

```bash
cd mobile/
flutter pub get
```

### Run (development)

```bash
# Point at a local backend
flutter run --dart-define=API_URL=http://192.168.x.x:8080/api/v1

# Point at the hosted production backend
flutter run --dart-define=API_URL=https://kukufiti-backend.onrender.com/api/v1
```

> **Note:** If `API_URL` is omitted in **release** mode and no URL has been saved in-app, a `ConfigErrorApp` overlay will block the UI and prompt the user to enter the backend URL manually. In debug mode the hardcoded `onrender.com` URL is used as fallback.

### Build release APK

```bash
flutter build apk \
  --release \
  --dart-define=API_URL=https://kukufiti-backend.onrender.com/api/v1
```

---

## Project Structure

```
mobile/
├── lib/
│   ├── main.dart                   # App entry point, bootstrap, ConfigErrorApp guard
│   ├── core/                       # Shared infrastructure (no feature logic)
│   │   ├── config/
│   │   │   └── app_config.dart     # API URL resolution (env var → Hive → default)
│   │   ├── network/
│   │   │   ├── api_client.dart     # Dio singleton with auth + offline interceptors
│   │   │   ├── api_client_provider.dart
│   │   │   ├── api_endpoints.dart  # All endpoint constants
│   │   │   └── sync_service.dart   # Offline write queue / replay
│   │   ├── router/
│   │   │   └── app_router.dart     # go_router config, auth redirect guard
│   │   ├── security/
│   │   │   └── biometric_service.dart
│   │   ├── storage/
│   │   │   ├── secure_storage_service.dart  # JWT token + remembered email (keychain/keystore)
│   │   │   └── hive_cache_service.dart      # Offline read cache
│   │   ├── theme/                  # AppTheme (light + dark)
│   │   ├── notifications/          # flutter_local_notifications setup
│   │   ├── utils/                  # Error handler, formatters
│   │   ├── models/                 # Shared domain models
│   │   ├── constants/
│   │   ├── error/
│   │   └── usecases/
│   │
│   ├── providers/                  # Root-level Riverpod providers
│   │   ├── auth_provider.dart      # AuthNotifier (login, logout, OTP, SSO)
│   │   ├── flock_providers.dart
│   │   ├── finance_providers.dart
│   │   ├── analytics_providers.dart
│   │   ├── billing_providers.dart
│   │   ├── broiler_provider.dart
│   │   └── ...                     # One provider file per feature domain
│   │
│   ├── presentation/               # Shared / cross-feature screens
│   │   ├── screens/
│   │   │   ├── auth/               # LoginScreen, RegisterScreen, OtpVerificationScreen, ProfileSetupScreen
│   │   │   ├── dashboard/          # DashboardScreen
│   │   │   ├── features/           # DailyChecksScreen, TasksScreen
│   │   │   ├── onboarding/         # BenefitsCarouselScreen
│   │   │   └── public/             # SplashScreen, FeaturesScreen, PricingScreen, …
│   │   ├── widgets/                # Reusable widgets
│   │   └── main_layout_screen.dart # Persistent bottom-nav shell (StatefulShellRoute)
│   │
│   └── features/                   # Feature-first modules (24 features)
│       ├── flock_management/
│       ├── feed_management/
│       ├── weight_management/
│       ├── mortality_management/
│       ├── vaccinations_management/
│       ├── expenses_management/
│       ├── sales_management/
│       ├── analytics_management/
│       ├── inventory_management/
│       ├── biosecurity_management/
│       ├── market_management/
│       ├── people_management/
│       ├── community_management/
│       ├── farm_management/
│       ├── ai_insights/
│       ├── alerts_management/
│       ├── calendar_management/
│       ├── reports_management/
│       ├── resources_management/
│       ├── profile_management/
│       ├── settings_management/
│       ├── vet_management/
│       ├── audit_logs_management/
│       └── admin_dashboard_management/
│
├── assets/
│   └── images/
│
├── android/
├── ios/
└── pubspec.yaml
```

Each feature module follows a **layered architecture**:
```
feature_name/
├── data/
│   ├── dtos/               # JSON deserialization (fromJson)
│   └── repositories/       # HTTP calls via ApiClient.instance
├── domain/
│   ├── entities/           # Pure Dart models (no framework dependencies)
│   ├── repositories/       # Abstract repository interfaces
│   └── usecases/           # Single-action use-cases (optional)
└── presentation/
    ├── controllers/        # Riverpod Notifiers (state + actions)
    └── screens/            # Flutter Widgets
```

---

## Architecture

### State Management — Riverpod

All state lives in **Riverpod providers**. The folder `lib/providers/` contains root-level providers (auth, flock selection, billing). Feature-specific state is in `feature/presentation/controllers/`.

Key pattern:
```dart
// Provider definition
final flockProvider = NotifierProvider<FlockNotifier, FlockState>(FlockNotifier.new);

// Notifier — holds business logic and calls repositories
class FlockNotifier extends Notifier<FlockState> { ... }

// Screen consumption
final state = ref.watch(flockProvider);
```

### Navigation — go_router

`lib/core/router/app_router.dart` configures the entire navigation graph.

**Auth redirect guard:**
- `isLoading == true` → do nothing, wait
- `isAuthenticated && path == /login|/register` → redirect to `/dashboard`
- `!isAuthenticated && path is protected` → redirect to `/login`
- `/otp-verify` and `/profile-setup` are exempt (must not redirect mid-auth-flow)

The router listens to `authProvider` via `_RouterRefreshListenable` and automatically re-evaluates redirects on any auth state change.

**Shell route:** Protected routes are wrapped in `StatefulShellRoute.indexedStack` with 5 branches, maintaining scroll position and state for each tab independently.

### Networking — Dio (`ApiClient`)

`lib/core/network/api_client.dart` is a lazy singleton (`ApiClient.instance`).

**Request interceptor:**
- Reads JWT from `SecureStorageService` (with a 2-second timeout guard to prevent Keystore hangs)
- Injects `Authorization: Bearer <token>` on every request

**Error interceptor:**
- Connection/timeout errors on **non-GET** requests → queued via `SyncService` → returns HTTP 202 to UI
- HTTP 401 → deletes stored auth token (auto-logout)

### Token Storage

Tokens are stored with `flutter_secure_storage` (Android Keystore / iOS Keychain):
```
Key: auth_token        → JWT bearer token
Key: remembered_email  → last used email (login UX)
Key: has_seen_intro    → onboarding skipped flag
```

### Offline Support

`lib/core/network/sync_service.dart` manages the Hive `offline_sync_queue` box.

- On connectivity error, non-GET requests are serialized and written to the queue
- On next successful request / app launch, the queue is drained in order
- Client-generated `event_id` UUIDs (passed to all event creation endpoints) make replays idempotent

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Declarative navigation with redirect guards |
| `dio` | HTTP client |
| `hive` + `hive_flutter` | Offline cache and sync queue |
| `flutter_secure_storage` | JWT token (Keystore / Keychain) |
| `fl_chart` | Analytics charts |
| `google_fonts` | Typography |
| `flutter_animate` | Micro-animations |
| `google_sign_in` | Google SSO |
| `sign_in_with_apple` | Apple SSO |
| `record` + `audioplayers` | Voice observations (AI feature) |
| `image_picker` | Disease photo upload |
| `flutter_local_notifications` | In-app push alerts |
| `pdf` + `printing` | Report PDF generation |
| `local_auth` | Biometric login |
| `intl` | Date/currency formatting (KES) |
| `freezed` + `json_serializable` | Code-gen for DTOs |
| `uuid` | Client-side event ID generation |

---

## Authentication

Three login methods, all converging on a stored JWT:

### 1. Email / Password
```
LoginScreen
  → AuthNotifier.login(email, password)
  → POST /auth/login
  → SecureStorageService.setAuthToken(token)
  → authProvider.isAuthenticated = true
  → Router redirects to /dashboard
```

### 2. OTP / Passwordless (Phone)
```
RegisterScreen or LoginScreen
  → POST /auth/send-otp { phone_number }

OtpVerificationScreen
  → POST /auth/verify-otp { phone_number, code }
  → response.is_new_user == true  → /profile-setup
  → response.is_new_user == false → /dashboard
```

### 3. Google / Apple SSO
```
LoginScreen
  → GoogleSignIn().signIn() or Apple signInWithApple()
  → POST /auth/google { id_token } or /auth/apple { identity_token }
  → AuthNotifier.loginWithToken(token)
  → Router redirects to /dashboard
```

---

## Feature Overview

| Feature | Route | Provider |
|---------|-------|---------|
| Dashboard | `/dashboard` | `broilerProvider`, `analyticsProvider` |
| Batches / Flocks | `/batches`, `/batch/:id` | `flockProvider` |
| Feed | `/feed`, `/feed-calculator` | Events API |
| Weight | `/weight` | Events API |
| Mortality | `/mortality` | Events API |
| Vaccinations | `/vaccinations` | Events API |
| Daily Checks | `/daily-checks` | `dataProviders` |
| Calendar | `/calendar` | Events / tasks |
| Tasks | `/tasks` | `taskProviders` |
| Finance | `/financials`, `/expenditures`, `/sales` | `financeProviders` |
| Analytics | `/analytics` | `analyticsProviders` |
| Market Prices | `/market` | `marketProviders` |
| Inventory | `/inventory` | `dataProviders` |
| Biosecurity | `/biosecurity` | `biosecurityProviders` |
| Vet / Health | `/vet` | `vetProviders` |
| People | `/people` | `peopleProviders` |
| Farms | `/farms` | Farm API |
| Community | `/community` | Community API |
| Resources | `/resources` | `resourcesProviders` |
| Alerts | `/alerts` | `alertsProviders` |
| AI Hub | `/ai-insights-hub` | AI API endpoints |
| Profile | `/profile` | `userProviders` |
| Settings | `/settings` | `settingsProvider` |
| Admin | `/admin` | `adminProviders` |
| Audit Logs | `/audit-logs` | `auditLogsProviders` |

---

## AI Advisory Features

All AI endpoints hit `POST /api/v1/ai/<endpoint>` and require a valid JWT.

| Screen | Route | Input |
|--------|-------|-------|
| Feed Advisory | `/ai-feed-advisory` | Age, weight, breed, bird count |
| Mortality Analysis | `/ai-mortality-analysis` | Daily mortality logs, breed, counts |
| Harvest Prediction | `/ai-harvest-prediction` | Current weight vs target weight |
| Disease Risk | `/ai-disease-risk` | Symptoms, vaccines, optional photo |
| FCR Insights | `/ai-fcr-insights` | Total feed consumed, flock mass |
| AI Chat | `/ai-chat` | Free-text message + history |
| Voice Observation | `/ai-voice-observation` | Audio file upload |
| Profit Optimizer | `/ai-profit-optimizer` | Feed cost, sale price, flock data |

---

## Subscription Plans

Plan enforcement happens **on the backend** — the mobile app checks the plan via `GET /billing/my-subscription` and shows/hides UI accordingly.

| Plan | Active Flocks | Bird Limit | History | AI Features |
|------|-------------|------------|---------|-------------|
| **Starter** | 1 | 100 | 90 days | ✗ |
| **Professional** | Unlimited | Unlimited | Full | ✓ |
| **Enterprise** | Unlimited | Unlimited | Full | ✓ + Team mgmt |

**M-Pesa payment flow:**
1. User selects plan + enters M-Pesa phone number
2. App calls `POST /billing/subscribe`
3. Backend triggers STK Push → user confirms on phone
4. Safaricom calls backend callback → subscription activated
5. App polls `/billing/my-subscription` to reflect new status

---

## Environment & Build

### API URL resolution (priority order)

1. `--dart-define=API_URL=...` at build time
2. User-saved URL in Hive `offline_cache['API_URL']`
3. Default: `https://kukufiti-backend.onrender.com/api/v1`

### Release build checklist

- [ ] Set correct `API_URL` via `--dart-define`
- [ ] Verify `AFRICASTALKING_API_KEY` is live (not sandbox) on backend
- [ ] Verify `MPESA_SHORTCODE` and `MPESA_PASSKEY` are production credentials
- [ ] Verify `GOOGLE_CLIENT_ID` matches the release signing key's SHA-1
- [ ] Confirm `MPESA_CALLBACK_URL` is publicly reachable (use ngrok for local testing)

---

## Docs

Detailed documentation is in the [`docs/`](docs/) folder:

| File | Contents |
|------|---------|
| [`docs/architecture.md`](docs/architecture.md) | Layered architecture, data flow, Riverpod provider graph |
| [`docs/design_system.md`](docs/design_system.md) | UI/UX design philosophy, color palette, and typography |
| [`docs/auth_flow.md`](docs/auth_flow.md) | Step-by-step auth sequences for all three paths |
| [`docs/api_reference.md`](docs/api_reference.md) | All API endpoints mapped to mobile features |
| [`docs/offline_support.md`](docs/offline_support.md) | Hive boxes, sync queue, idempotency |
| [`docs/feature_guide.md`](docs/feature_guide.md) | Per-feature screen descriptions and state flows |
