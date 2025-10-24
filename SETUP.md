# Setup Guide

This guide will walk you through setting up the Giro Jogos Flutter project from scratch.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (version 3.16.0 or higher)
  - Download from: https://flutter.dev/docs/get-started/install
- **Dart SDK** (comes with Flutter)
- **Git**
- **Firebase CLI**
  - Install: `npm install -g firebase-tools`
- **FlutterFire CLI**
  - Install: `dart pub global activate flutterfire_cli`

### Platform-Specific Requirements

#### For Android Development
- Android Studio or Android SDK
- Android SDK 21 or higher
- Java Development Kit (JDK) 8 or higher

#### For iOS Development (macOS only)
- Xcode 12 or higher
- CocoaPods: `sudo gem install cocoapods`

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/guitcastro/giro-jogos-flutter.git
cd giro-jogos-flutter
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### 3.1 Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `giro-jogos`
4. Follow the setup wizard

#### 3.2 Enable Firebase Services

In your Firebase project console:

1. **Authentication**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password" provider

2. **Firestore Database**
   - Go to Firestore Database
   - Click "Create database"
   - Start in test mode (we'll deploy security rules later)

3. **Storage**
   - Go to Storage
   - Click "Get started"
   - Start in test mode

4. **Hosting** (for Web/PWA)
   - Go to Hosting
   - Click "Get started"
   - Follow the setup wizard

#### 3.3 Configure Firebase for Flutter

```bash
# Login to Firebase
firebase login

# Configure FlutterFire
flutterfire configure --project=giro-jogos
```

This command will:
- Create/update `lib/firebase_options.dart`
- Register your app with Firebase for each platform
- Download configuration files

#### 3.4 Deploy Firebase Rules

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage:rules
```

### 4. Platform-Specific Setup

#### Android

No additional setup required. The project is pre-configured.

To run on Android:
```bash
flutter run
# or specify the device
flutter run -d android
```

#### iOS

1. Navigate to the iOS directory:
```bash
cd ios
pod install
cd ..
```

2. Open the project in Xcode to configure signing:
```bash
open ios/Runner.xcworkspace
```

3. In Xcode:
   - Select the Runner project
   - Go to "Signing & Capabilities"
   - Select your development team
   - Change the bundle identifier if needed

To run on iOS:
```bash
flutter run -d ios
```

#### Web/PWA

No additional setup required for local development.

To run on Web:
```bash
flutter run -d chrome
```

### 5. Verify Installation

Run the test suite to ensure everything is working:

```bash
flutter test
```

Run static analysis:

```bash
flutter analyze
```

### 6. GitHub Actions Setup (Optional)

To enable automatic deployment to Firebase Hosting:

1. Create a Firebase service account:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Click "Generate New Private Key"
   - Save the JSON file securely

2. Add the service account to GitHub Secrets:
   - Go to your GitHub repository → Settings → Secrets
   - Add a new secret named `FIREBASE_SERVICE_ACCOUNT`
   - Paste the entire JSON content

Now pushes to the `main` branch will automatically deploy to Firebase Hosting.

## Running the Application

### Development Mode

```bash
# Mobile (connects to a device or emulator)
flutter run

# Web
flutter run -d chrome

# Specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

### Production Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release

# Web
flutter build web --release
```

## Accessing the Admin Panel

1. Start the application
2. Navigate to the `/admin` route
3. Sign in with your Firebase credentials

## Troubleshooting

### Common Issues

**Issue: "Firebase not configured"**
- Solution: Run `flutterfire configure` again

**Issue: "Pod install failed" (iOS)**
- Solution: Update CocoaPods: `sudo gem install cocoapods`
- Clean and reinstall: `cd ios && pod deintegrate && pod install`

**Issue: "Gradle build failed" (Android)**
- Solution: Clean the build: `flutter clean && flutter pub get`

**Issue: "Unable to connect to Firebase"**
- Solution: Check your internet connection
- Verify Firebase configuration in `lib/firebase_options.dart`

### Getting Help

- Check the [README.md](README.md) for general information
- Review [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines
- Open an issue on GitHub for bugs or questions

## Next Steps

- Read the [README.md](README.md) for project overview
- Check [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines
- Explore the codebase starting from `lib/main.dart`
- Review Firebase security rules in `firestore.rules` and `storage.rules`

Happy coding! 🚀
