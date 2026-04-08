# Authentication Flows

KukuFiti supports three main authentication methods. All flows ultimately resolve to standardizing on a JWT (JSON Web Token) assigned by the FastAPI backend, which is subsequently passed via the `Authorization: Bearer <token>` header for all API calls.

## 1. Passwordless OTP (Phone Number)

This is the primary flow for farmers, as phone numbers are highly accessible.

**Sequence:**
1. **Request OTP**: User enters phone number. App normalizes it (e.g. `07XX` to `2547XX`).
2. **API Call**: `POST /auth/send-otp` is called.
3. **Backend Action**: Redis rate-limits the request (max 3/15m). Backend generates a 4-digit code, stores it in Redis with a 5-minute TTL, and fires an Africa's Talking SMS API request asynchronously.
4. **Verification**: User receives SMS and inputs code.
5. **API Call**: `POST /auth/verify-otp` with `{ phone_number, code }`.
6. **Backend Verification**: Backend matches the code in Redis, deletes it, and provisions a User row if it's a new number. Returns JWT and `is_new_user` flag.
7. **App Router**: If `is_new_user == true`, the app routes to `/profile-setup` so the user can enter their name/location. If `false`, routes to `/dashboard`.

## 2. Standard Email & Password

**Sequence:**
1. **Registration**: User completes the form in `RegisterScreen`.
2. **API Call**: `POST /auth/register` sends `{email, password, full_name, phone, location}`.
3. **Backend Action**: Bcrypt hashes the password, creates User.
4. **Login**: User inputs credentials in `LoginScreen`.
5. **API Call**: `POST /auth/login`.
6. **Backend Verification**: Compares hash, returns JWT.

## 3. Social SSO (Google & Apple)

**Sequence (Google):**
1. **Client OAuth**: Flutter uses `google_sign_in` plugin to interact with the device's native Google account manager.
2. **Retrieve Token**: The plugin returns a Google-issued `id_token`.
3. **API Call**: `POST /auth/google` with the `id_token`.
4. **Backend Verification**: The backend calls Google's `tokeninfo` endpoint to verify the token signature and checks the `aud` (audience) claim matches the app's `GOOGLE_CLIENT_ID`.
5. **User Sync**: Extracts email and name, maps to an existing KukuFiti account or creates a new one. Returns JWT + `is_new_user`.

**Sequence (Apple):**
1. **Client OAuth**: Flutter uses `sign_in_with_apple`.
2. **Retrieve Token**: Returns an Apple `identity_token`.
3. **API Call**: `POST /auth/apple` with `identity_token` + `fullName`.
4. **Backend Verification**: Fetches Apple's public JWKS keys, verifies the JWT signature (RS256) locally, checks audience against app's identifier. Maps email to KukuFiti account. Returns JWT.

## Local Session Management

Once a JWT is acquired via any flow:
1. `SecureStorageService.setAuthToken(token)` encrypts the token in the Android Keystore / iOS Keychain.
2. `AuthNotifier` sets `isAuthenticated = true`.
3. `ApiClient.instance` automatically attaches the token to all future requests.
4. If a request returns `401 Unauthorized`, the interceptor wipes the token and triggers a logout.
