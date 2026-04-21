# Android setup and Play Store release

## 1. Install local tooling

- Flutter SDK
- Android Studio
- Android SDK Platform 35
- Java 17

Run:

```bash
flutter doctor
```

## 2. Create the missing local Android config files

Copy:

- `android/local.properties.example` -> `android/local.properties`
- `android/key.properties.example` -> `android/key.properties` when you are ready for release signing

Fill in:

- `flutter.sdk`
- `sdk.dir`

Generate the local Gradle wrapper JAR if it is missing:

```bash
cd android
gradle wrapper
```

`gradle-wrapper.jar` is a generated binary, so it is not included here.

## 3. Add Firebase Android config

Download `google-services.json` from your Firebase project and place it at:

```text
android/app/google-services.json
```

Important:

- The Firebase Android app package name must match `com.smart.expensetracker`
- Add SHA-1 and SHA-256 fingerprints in Firebase for Google Sign-In

## 4. Generate an upload keystore

```bash
keytool -genkeypair -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Then update `android/key.properties`.

## 5. Build a release app bundle

```bash
flutter pub get
flutter build appbundle --release
```

The Play Store upload file will be created at:

```text
build/app/outputs/bundle/release/app-release.aab
```

## 6. Play Console checklist

- Create app in Play Console
- Upload `app-release.aab`
- Complete App Content forms
- Add privacy policy URL
- Add screenshots, icon, and feature graphic
- Set app category and content rating
- Add testers for internal testing first

## 7. Recommended production polish

- Replace the temporary vector launcher icon with branded Play Store assets
- Add Crashlytics and Analytics
- Add real FCM background message handling
- Add Play Integrity / App Check if you keep Firebase public endpoints
