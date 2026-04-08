# API Reference Mapping

This guide maps the mobile app's core functionalities to their corresponding FastAPI endpoints. All API paths are prefixed with `${API_URL}` (e.g., `http://domain.com/api/v1`).

Authentication requires the `Authorization: Bearer <token>` header for all routes EXCEPT those under `/auth` (excluding `/auth/me`).

## 1. Authentication
Handles JWT generation, SSO, and OTP sending.

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST   | `/auth/login` | Email/password login |
| POST   | `/auth/register` | Register new user via Email |
| POST   | `/auth/send-otp` | Sends SMS via AfricasTalking. Payload: `{phone_number}` |
| POST   | `/auth/verify-otp` | Verifies SMS code. Payload: `{phone_number, code}` |
| POST   | `/auth/google` | Validates Google `id_token` |
| POST   | `/auth/apple` | Validates Apple `identity_token` |
| GET    | `/auth/me` | Fetch authenticated user's profile |
| PUT    | `/auth/me` | Update full_name, phone, county, etc. |

## 2. Core Entities
CRUD operations for physical farm elements.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST | `/flocks/` | Fetch all batches, or create a new batch |
| GET/PUT  | `/flocks/{flock_id}` | Fetch/Update single batch |
| GET/POST | `/farms/` | Manage multi-farm tenant settings |
| GET/POST | `/inventory/` | Fetch/add warehouse supplies and stock |
| GET/POST | `/people/` | Manage Employees, Suppliers, Customers |

## 3. Daily Operations (Events)
All events require `?flock_id=<UUID>` parameter.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST | `/events/feed` | Log feed consumption in kg |
| GET/POST | `/events/weight` | Log average bird sampling weight |
| GET/POST | `/events/mortality` | Log deceased birds and cause |
| GET/POST | `/events/vaccination`| Log vaccine administration |
| GET/POST | `/daily-checks/`| Global struct covering water, temp, litter status |

## 4. Finance & Billing
Financial logs and Daraja MPesa integration.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/POST | `/finance/expenditures` | Log an expense. Restricted categories on Starter. |
| GET/POST | `/finance/sales` | Record a sale. Can trigger STK push if `buyer_phone` included. |
| GET    | `/finance/export` | Download CSV (Professional Plan only) |
| GET    | `/billing/plans` | Fetch available dynamic subscription tiers |
| GET    | `/billing/my-subscription` | Fetch current active sub and renewal dates |
| POST   | `/billing/subscribe` | Pay for plan via M-Pesa STK Push |

## 5. Artificial Intelligence
Routes proxy prompts to OpenAI/Gemini through the backend to avoid leaking API keys into the mobile client. Always returns strict JSON.

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST   | `/ai/chat` | General chatbot conversational flow |
| POST   | `/ai/feed-recommendation` | Returns optimal `daily_feed_kg` |
| POST   | `/ai/mortality-analysis` | Checks mortality logs against benchmarks |
| POST   | `/ai/harvest-prediction` | Days to target market weight |
| POST   | `/ai/disease-risk` | Symptom diagnostics (supports image base64) |
| POST   | `/ai/fcr-insights` | FCR rating (Excellent, Good, Poor) |
| POST   | `/ai/voice-record` | Submits audio as `multipart/form-data` |

## 6. Social & Community
The discussion forum API.

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | `/community/categories` | Forum sub-boards (General, Health, etc) |
| GET    | `/community/feed` | Paginated global search feed |
| POST   | `/community/posts` | Create thread |
| POST   | `/community/posts/{post_id}/like` | Toggle Like logic |
| GET/POST | `/community/posts/{post_id}/comments` | Fetch/Post replies |
