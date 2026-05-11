# HeritageLens
## Documentation

> *See cultural artifacts through a lens of the past.*

HeritageLens is a mobile application built with **Flutter** and **Unity** that allows users to find, add, and experience cultural artifacts through **3D models** and **Augmented Reality** — from anywhere in the world.

Whether you are a teacher bringing history to life in the classroom, a student or tourist exploring the origins of a civilization, or a community determined to preserve its heritage across generations, HeritageLens puts the past right in front of you.

---

## What is HeritageLens?

Rapid technological advancement and globalization are quietly eroding traditional cultural practices and languages. UNESCO estimates that one language dies every two weeks. As the world grows more connected and culturally homogeneous, the need to actively preserve and share heritage has never been more urgent — especially across Africa.

HeritageLens answers that need. It is a platform where culture is not locked behind museum walls or geographic borders. Through AR, users can place and interact with 3D models of cultural artifacts in their physical environment, explore the history and origins of those artifacts in detail, and share that experience with others — all from a smartphone.

**Key capabilities include:**
- Viewing and interacting with cultural artifacts as 3D AR models
- Adding artifacts to a shared space where multiple users can view, place, and comment on models in real time
- Scanning QR codes at physical museum exhibits to instantly pull up the corresponding 3D model and its historical context
- Maximum device compatibility: HeritageLens uses **ARCore** as its primary AR engine and falls back to the **Vuforia Engine** for devices where ARCore is not supported

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile Framework | Flutter |
| 3D / AR Runtime | Unity |
| AR Engine (primary) | ARCore |
| AR Engine (fallback) | Vuforia Engine |
| Backend / Auth | Firebase |

---

## Getting Started

### Prerequisites

Make sure you have the following installed and configured on your machine before proceeding:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel recommended)
- [Dart](https://dart.dev/get-dart) (bundled with Flutter)
- [Git](https://git-scm.com/)
- A connected Android device or emulator with AR support (for full AR functionality)

---

### 1. Clone the Repository

```bash
git clone https://github.com/your-org/heritagelens.git
cd heritagelens
```

---

### 2. Add the Firebase Configuration File

The `firebase_options.dart` file is **not included in the repository** for security reasons. You will need to obtain it from the project maintainer and place it manually.

Once you have the file, add it to:

```
lib/firebase_options.dart
```

> ⚠️ **The app will not build or run without this file.** Do not commit it to version control.

---

### 3. Install Dependencies

```bash
dart pub get
```

---

### 4. Run the App

```bash
flutter run
```

This will launch the app on your connected device or running emulator.

---

### 5. Build a Release APK (Optional)

To build a production-ready APK:

```bash
flutter build apk --release
```

The output APK will be located at:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Project Structure

```
heritagelens/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart   ← Add this manually (not in repo)
│   └── ...
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## Notes

- **Firebase options are secret.** Never push `firebase_options.dart` to a public or shared repository. Add it to your `.gitignore` if it is not already there.
- **AR compatibility** is handled automatically. On devices that do not support ARCore, the app will switch to the Vuforia Engine fallback to ensure the experience is accessible to as wide a user base as possible.
- **Unity integration** requires that the Unity build artifacts be present in the project. If you are setting up from scratch, contact the project maintainer for the Unity-generated module.

---

## Contributing

This project is part of the **ETSIA** initiative. For access, contribution guidelines, or to report issues, please reach out to the project team directly.

---

*HeritageLens — preserving the past, accessible to all.*
