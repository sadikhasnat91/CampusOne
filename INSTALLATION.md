# CampusOne Installation & Build Guide 🛠️

This document provides complete instructions for developers and maintainers to set up, build, test, and package **CampusOne** as an Android APK.

---

## 📋 Prerequisites

Ensure you have the following installed on your machine:
- **Flutter SDK**: `3.12.x` or later ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK**: `3.12.x` or later (included with Flutter)
- **Android Studio** / **VS Code** with Flutter extensions
- **Android SDK & Build Tools**: API 21 (Android 5.0) or higher

---

## ⚡ Setup & Dependency Installation

1. **Clone or Navigate to the Workspace**:
   ```bash
   cd e:/campusone
   ```

2. **Install Flutter Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Project Health**:
   ```bash
   flutter analyze
   ```

4. **Run Unit & Widget Tests**:
   ```bash
   flutter test
   ```

---

## 📱 Running the Application

### Debug Mode (Device or Emulator):
Connect an Android device via USB (or start an emulator) and run:
```bash
flutter run
```

---

## 📦 Building Production Release APK

To generate a standalone APK for Android deployment:

1. **Build Release APK**:
   ```bash
   flutter build apk --release
   ```

2. **Output APK Location**:
   The output APK will be saved at:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 🛠️ Code Generation (Hive Database)

If you modify any Hive model `@HiveType` or `@HiveField` annotations, run the `build_runner` code generator:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📬 Support & Troubleshooting

- If biometric lock fails on emulator, verify emulator security settings or enable pin/pattern unlock.
- For backup import issues, ensure `.campusone` file permissions are granted on the target device.
