# App Flow Correction TODO

## Current Issue
- App starts with Welcome Screen, then animation completes and navigates to Home Screen (already skips onboarding).
- User wants flow: Welcome >> Home >> Login >> KYC >> Login >> Dashboard.

## Completed Changes

### 1. Skip Onboarding (Get Started) Screen
- **File:** `frontend/front/lib/screens/welcome_screen.dart`
- **Status:** Already implemented - welcome screen navigates directly to HomeScreen after animation.

### 2. Redirect First Login to KYC
- **File:** `frontend/front/lib/screens/login_screen.dart`
- **Status:** Completed - Changed navigation after signup to '/payment-verification' instead of DashboardScreen.

### 3. Add NextLogin Route to Main
- **File:** `frontend/front/lib/main.dart`
- **Status:** Completed - Added '/nextlogin': (context) => const NextLogin(), to the routes map.

### 4. Redirect KYC Completion to Second Login
- **File:** `frontend/front/lib/screens/payment_verification_screen.dart`
- **Status:** Completed - Changed navigation after KYC submission to '/nextlogin' instead of popping back.

### 5. Ensure Second Login Goes to Dashboard
- **File:** `frontend/front/lib/screens/nextlogin.dart`
- **Status:** Already implemented - Navigates to DashboardScreen on successful login.

## Flow Summary
1. Welcome Screen -> Home Screen (skips onboarding)
2. Home Screen -> Login Screen (signup)
3. Login Screen -> Payment Verification (KYC)
4. Payment Verification -> NextLogin (actual login)
5. NextLogin -> Dashboard

## Testing
- Run the app and verify the flow: Welcome -> Home -> Login -> KYC -> Login -> Dashboard
- Ensure no "get started" screen appears.
