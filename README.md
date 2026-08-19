# 🚀 Flutter Task Manager

A professional-grade Flutter application for task management built with **Clean Architecture**, **BLoc** state management, and an **Offline-First** synchronization strategy using **SQFLite** and **Firebase Cloud Firestore**.

---

## 🏗️ Architecture

The project follows a strict **Clean Architecture** pattern to ensure a decoupled, testable, and maintainable codebase.

### Layers:
1.  **Domain Layer (`lib/domain`)**:
    *   **Entities**: Pure business objects (`TaskEntity`) that are independent of any external libraries.
    *   **Repositories**: Abstract contracts defining how data should be handled.
2.  **Data Layer (`lib/data`)**:
    *   **Models**: Data Transfer Objects (DTOs) with automated **JSON serialization** (`TaskModel`).
    *   **Data Sources**: Concrete implementations for **SQFLite** (local) and **Cloud Firestore** (remote).
    *   **Repositories Implementation**: The "brain" that manages data flow, user scoping, and background synchronization.
3.  **Presentation Layer (`lib/presentation`)**:
    *   **BLocs**: Handles UI state logic (`TaskBloc`, `AuthBloc`, `ThemeBloc`).
    *   **UI**: Material 3 components with adaptive styling for a modern user experience.

---

## ✨ Key Features

*   🔐 **Firebase Authentication**: Full Login and Signup flow. All task data is securely scoped to the individual user.
*   🔄 **Offline-First Sync**: Create, edit, or delete tasks without internet. The app automatically syncs local changes to Firestore when connection is restored.
*   🎨 **Beautiful Teal UI**: A custom-designed interface with a signature teal identity.
*   🌓 **Dynamic Theme**: Instant switching between high-quality **Light and Dark modes**.
*   🔍 **Local Search & Filter**: High-performance local search by title/description and status-based filtering (All, Pending, Completed).
*   📅 **Smart Sorting**: Organize tasks by Due Date or Priority (High, Medium, Low).
*   ⚡ **GoRouter Navigation**: Declarative and type-safe routing throughout the app.
*   ✅ **Real-time Validation**: Form fields provide instant feedback to guide the user.

---

## 🛠️ Setup Instructions

### 1. Prerequisites
*   Flutter SDK (v3.x.x)
*   Firebase Project

### 2. Firebase Configuration
1.  Add an **Android app** in your Firebase Console with package: `com.example.ethic_fin_task2`.
2.  Download `google-services.json` and place it in `android/app/`.
3.  **Enable Services**:
    *   **Authentication**: Enable `Email/Password` provider.
    *   **Firestore Database**: Create a database in `Test Mode`.

### 3. Installation & Build
```bash
# Install dependencies
flutter pub get

# Generate serialization and mock code
dart run build_runner build --delete-conflicting-outputs
```

### 4. Running the App
```bash
flutter run
```

---

## 🧪 Testing Suite

The project maintains high code quality through automated testing:
*   **Unit Tests**: Validates BLoc state transitions and business logic.
*   **Widget Tests**: Ensures UI components and navigation paths are reliable.

**Run all tests**:
```bash
flutter test
```

---

## 📦 Technical Stack
*   **State Management**: `flutter_bloc`
*   **Navigation**: `go_router`
*   **Local DB**: `sqflite`
*   **Cloud DB**: `cloud_firestore`
*   **Auth**: `firebase_auth`
*   **Network**: `connectivity_plus`
*   **Serialization**: `json_serializable`
