# Task Manager Application

A modern Flutter Task Manager application built with Clean Architecture, BLoc state management, Firebase Cloud Firestore, and SQLite local storage.

## Features

- **Task Management**: Create, Read, Update, and Delete tasks.
- **Offline First**: Full local persistence using SQFLite. The app remains functional without internet.
- **Cloud Sync**: Automatic synchronization with Firebase Cloud Firestore when connectivity is restored.
- **Search & Filtering**: Instant local search by title, and filtering by status (All, Pending, Completed).
- **Sorting**: Sort tasks by Due Date or Priority.
- **Modern UI**: Beautiful Teal theme supporting both Light and Dark modes.
- **Navigation**: Uses `go_router` for structured and type-safe navigation.
- **Form Validation**: Real-time validation for task creation and editing.

## Architecture

The project follows **Clean Architecture** principles:
- **Domain Layer**: Entities and Repository interfaces.
- **Data Layer**: Models (with `json_serializable`), Repository implementations, and Data Sources (Firestore & SQLite).
- **Presentation Layer**: BLocs for state management and modern Flutter widgets.

## Technical Stack

- **Framework**: Flutter
- **State Management**: flutter_bloc
- **Local Database**: sqflite
- **Remote Database**: Cloud Firestore
- **Navigation**: go_router
- **Networking**: connectivity_plus
- **Code Generation**: build_runner, json_serializable

## Getting Started

1.  **Firebase Setup**:
    - Add your `google-services.json` to `android/app/`.
    - Enable **Firestore Database** in the Firebase Console.
2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run Code Generation**:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
4.  **Run the App**:
    ```bash
    flutter run
    ```

## Testing

The project includes both unit and widget tests:
- **Unit Tests**: `test/presentation/blocs/task/task_bloc_test.dart`
- **Widget Tests**: `test/presentation/screens/`

Run all tests using:
```bash
flutter test
```
