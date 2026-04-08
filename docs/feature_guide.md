# Feature Guide

KukuFiti divides its functionality into logical domains. Here is an overview of key modules, their corresponding screens, and their underlying providers.

## Dashboard (`/dashboard`)
**Primary Screen:** `DashboardScreen`
**Providers:** `broilerProvider`, `analyticsProvider`
The landing page upon opening the app. Pulls aggregated KPIs from the backend `/analytics/dashboard-metrics` (total birds, revenue, FCR). Provides quick action buttons for daily operational logging (Record Feed, Record Mortality, etc.).

## Flock Management (`/batches`)
**Screens:** `FlocksScreen`, `BatchesScreen`, `BatchDetailsScreen`
**Providers:** `flockProvider`
A "Flock" or "Batch" represents a discrete lifecycle of birds. Users can create a batch (limited to 1 on the Starter plan), define its start date and breed. The `BatchDetailsScreen` drills down into live metrics specific to that flock.

## Daily Operations (`/feed`, `/weight`, `/mortality`, `/vaccinations`)
**Screens:** `FeedScreen`, `WeightScreen`, `MortalityScreen`, `VaccinationsScreen`, `DailyChecksScreen`
These screens allow farmers to log daily inputs. Every log requires selecting an active Batch to tie the event to a specific flock's ID. Data logged here directly influences the AI Advisory outputs and FCR metrics.

## AI Advisory Hub (`/ai-insights-hub`)
**Screens:** 
- `FeedAdvisoryScreen`
- `MortalityAdvisoryScreen`
- `HarvestPredictionScreen`
- `DiseaseRiskScreen`
- `FcrInsightsScreen`
- `AiChatScreen`
- `VoiceObservationScreen`
- `HarvestOptimizationScreen`

The AI Hub leverages either OpenAI or Gemini. Depending on the screen, it pulls local state (e.g., current flock age, daily mortality logs) and packages it into a prompt payload sent to the backend. The backend enforces a strict JSON schema for the AI's response, which the UI predictably parses and renders (e.g., rendering "EXCELLENT", "GOOD", or "POOR" for FCR Insights).

**Voice Observation**: Uses the `record` package to capture microphone audio, saves to a temp file, and POSTs multipart/form-data to the backend for whisper-transcription and AI observation extraction.

## Financials (`/financials`)
**Screens:** `FinancialsScreen`, `ExpendituresScreen`, `SalesScreen`
**Providers:** `financeProviders`
Tracks expenses (categorized) and revenue.
On the Starter plan, expense categories are restricted to predefined types (Feed, Labor, etc.). Creating a Sale entry equipped with a buyer phone number triggers an automatic M-Pesa STK Push to collect the payment.

## Analytics & Reporting (`/analytics`)
**Screens:** `AnalyticsScreen`, `ReportsScreen`
Visually maps business health. Uses `fl_chart` to render data.
The "Revenue vs Expenses" chart is gated behind the Professional subscription plan. Regional Benchmarking (comparing farm performance against others in the same Kenyan county) requires the user's `county` to be populated in their profile.

## Community (`/community`)
**Screens:** `CommunityFeedScreen`, `PostDetailScreen`, `CreatePostScreen`
A specialized social network. Features categorized posts, threaded replies, and a "like" system.

## Settings & Business Management (`/settings`)
**Screens:** `SettingsScreen`, `ProfileScreen`, `FarmsScreen`, `PeopleScreen`, `ResourcesScreen`
Handles multi-farm setups, employee definitions, educational PDF guides (Resources), and subscription plans. 
Here, users can hit the `manage subscriptions` flow, which leverages the backend M-Pesa Daraja integration to process payments and unlock Professional/Enterprise tiers.

## Admin & Management Overview (`/admin`)
**Screens:** `AdminDashboardScreen`, `ManageUsersScreen`, `AuditLogsScreen`
**Providers:** `adminProviders`, `auditLogsProviders`

- **Admin Dashboard**: Real-time platform metrics (User growth, revenue via M-Pesa).
- **User Management**: Allows admins to promote users to `ADMIN`, `MANAGER`, or `VIEWER` roles.
- **Audit Logs**: A read-only stream of critical system actions (e.g., login attempts, plan changes, flock deletions) used for security and troubleshooting.
- **Resources Management**: Allows admins to upload and categories PDF/MarkDown guides for all farmers.
