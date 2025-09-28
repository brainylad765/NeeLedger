# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

BlockZen is a Flutter-based mobile-first application for evidence collection and document management, previously known as NeeLedger. The app features real-time Firebase integration, AI-powered image analysis, and cross-platform compatibility (Web, Android, iOS).

## Development Commands

### Flutter Development
```powershell
# Install dependencies
flutter pub get

# Run the app (web development)
flutter run -d chrome

# Run with hot reload enabled
flutter run -d chrome --hot

# Run with specific web renderer
flutter run -d chrome --web-renderer html --enable-software-rendering

# Build for production
flutter build web

# Run tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Clean build artifacts
flutter clean
```

### Firebase Functions
```powershell
# Navigate to functions directory
cd front/functions

# Install dependencies
npm install

# Build TypeScript functions
npm run build

# Run Firebase emulator
npm run serve

# Deploy functions to Firebase
npm run deploy

# View function logs
npm run logs
```

### Firebase Development
```powershell
# Initialize Firebase hosting
firebase init hosting

# Deploy to Firebase hosting
firebase deploy

# Run Firebase emulators
firebase emulators:start
```

## Architecture Overview

### Core Structure
- **Provider Pattern**: Uses Flutter Provider for state management across 5 main providers
- **Firebase Integration**: Real-time data sync using Firestore and Firebase Storage
- **Cross-Platform**: Single codebase for web, mobile, and desktop with platform-specific services
- **Mobile-First UI**: Constrains desktop width to ~420px for mobile-like experience

### Key Providers
- `EvidenceProvider`: Handles image/PDF uploads, AI analysis, Firebase storage
- `DocumentProvider`: Manages document uploads and metadata
- `UserProvider`: User authentication and profile management
- `TransactionProvider`: Financial transaction tracking
- `UploadProvider`: Generic file upload functionality

### Firebase Architecture
- **Collections**: `evidence`, `documents`, `transactions`, `users`
- **Storage**: Evidence files stored in `/evidence/` folder
- **Authentication**: Uses Firebase Auth (currently using placeholder "current_user")
- **Real-time**: All data syncs instantly across devices

### AI/ML Integration
- **TensorFlow Lite**: Object detection using YOLOv8 model on mobile
- **Image Processing**: OpenCV-style image enhancement using `image` package
- **Web Fallback**: Simplified AI processing for web platform
- **Custom Detection**: Platform-conditional AI services (`ai_service_mobile.dart` / `ai_service_web.dart`)

### UI/UX Features
- **Custom Map**: Non-interactive map with GPS coordinates using CustomPainter
- **Dark Theme**: Material Design dark theme with custom color palette
- **Responsive Design**: Adapts to different screen sizes while maintaining mobile feel
- **Real-time Updates**: Live progress indicators and instant sync feedback

## Project Structure

```
lib/
├── main.dart                 # App entry point with provider setup
├── models/                   # Data models (Evidence, User, Transaction)
├── providers/                # State management (5 core providers)
├── screens/                  # UI screens organized by feature
│   ├── blockzen/            # BlockZen-specific screens
│   └── [other screens]      # Main app screens
├── services/                # External integrations
│   ├── firebase_service.dart # Firebase operations
│   ├── ai_service_*.dart    # Platform-specific AI services
│   └── api_service.dart     # HTTP API calls
└── utils/
    └── constants.dart       # App colors, themes, and constants
```

### Critical Files
- `lib/providers/evidence_provider.dart`: Core file handling image uploads, AI analysis, and Firebase integration
- `lib/services/firebase_service.dart`: All Firebase operations and real-time listeners
- `pubspec.yaml`: Dependencies including Firebase, AI/ML, camera, and location services
- `lib/main.dart`: App initialization with Firebase setup and provider configuration

## Development Workflow

### Adding New Features
1. Update relevant Provider for state management
2. Add new screens/widgets in appropriate folders
3. Update Firebase security rules if needed
4. Test across web and mobile platforms

### Firebase Development
- Evidence and documents auto-sync across devices
- User authentication currently uses placeholder - implement proper Firebase Auth
- Security rules need implementation for production use

### Testing Strategy
- Test image uploads on web browser first
- Verify Firebase integration in Firebase Console
- Test cross-device synchronization
- Check AI/ML functionality on mobile vs web

### Platform-Specific Notes
- **Web**: Uses blob URLs for file handling, simplified AI processing
- **Mobile**: Full TensorFlow Lite support, native camera integration
- **Desktop**: Mobile UI constraints applied for consistency

## Common Issues & Solutions

### Firebase Upload Issues
- Enable browser console to debug Firebase initialization
- Check network tab for upload progress
- Verify Firebase Storage and Firestore rules

### AI/ML Model Loading
- TensorFlow Lite models only work on mobile platforms
- Web platform uses fallback image processing
- Models stored in `assets/models/` directory

### Cross-Platform File Handling
- Web uses `Uint8List` for file bytes
- Mobile uses `File` objects
- Provider handles platform detection automatically

## Dependencies

### Core Flutter Packages
- `provider`: State management
- `firebase_core`, `firebase_auth`, `firebase_storage`, `cloud_firestore`: Firebase integration
- `image_picker`, `camera`: Media capture
- `geolocator`, `permission_handler`: Location services
- `flutter_map`, `latlong2`: Map functionality

### AI/ML & Processing
- `tflite_flutter`: TensorFlow Lite for mobile
- `image`: Image processing (OpenCV replacement)
- `http`: API calls

### UI/UX
- `google_fonts`: Typography (Poppins font)
- `uuid`: Unique identifier generation

## Development Notes

### Current Status
- Firebase integration is functional with real-time sync
- Image and PDF upload systems are working
- AI object detection implemented with platform detection
- Authentication uses placeholder - needs proper implementation

### Immediate Priorities
1. Implement proper Firebase Authentication
2. Deploy to production hosting (Firebase Hosting recommended)
3. Set up Firebase security rules
4. Test cross-device synchronization thoroughly

### Known Limitations
- User authentication is placeholder-based ("current_user")
- AI/ML features are simplified on web platform
- Map integration is visual-only (no real map tiles)