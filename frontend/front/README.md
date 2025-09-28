# front

NeeLedger frontend (modified)

This project has been updated to include a mobile-first UI and a Profile screen with:

- Embedded map using `flutter_map` (OpenStreetMap tiles).
- Camera and gallery upload flow using `image_picker`.
- Location access via `geolocator` and `permission_handler` (asks when capturing evidence).
- An `EvidenceProvider` with a mocked XAI report generator for uploaded evidence.

Run locally:

```powershell
flutter pub get
flutter run
```

Notes:
- On desktop, the app constrains its width to ~420px to emulate mobile layout.
- Add required native permissions when building on Android/iOS (camera, location).
- Replace the mocked XAI generator with real ML/backend calls as needed.
