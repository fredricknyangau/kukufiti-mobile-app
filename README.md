# mobile

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Running with the backend

This app communicates with a backend API. The base URL is injected at build time using `--dart-define`.

Example (local development):

```bash
flutter run --dart-define=API_URL=http://localhost:8000/api/v1
```

For release builds or CI, make sure to set a real backend URL (the app will throw on startup in release builds if it is still using the default localhost URL).
