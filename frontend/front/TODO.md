# TODO: Update Flutter Project

## 1. Permissions
- [ ] Add extra permissions to AndroidManifest.xml
- [ ] Add extra privacy strings to Info.plist
- [ ] Add permissions to web/index.html if needed

## 2. Dependencies
- [ ] Add opencv_4, shared_preferences, js to pubspec.yaml

## 3. Providers
- [ ] Update user_provider.dart to use shared_preferences for persistence
- [ ] Update evidence_provider.dart to integrate OpenCV/YOLO for analysis

## 4. Screens
- [ ] Update profile_screen.dart to use user_provider and enhance UI
- [ ] Update new_project_form.dart to remove mock message

## 5. Web Integration
- [ ] Add opencv.js script to web/index.html
- [ ] Create JS interop for OpenCV on web

## 6. Testing
- [ ] Run flutter pub get
- [ ] Test on Android/iOS/Web
