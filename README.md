# 📱 Code Center

**Code Center** is a robust and scalable Flutter application designed to manage and distribute promotional codes and rewards. It serves as a unified codebase for multiple application flavors, ensuring consistency while allowing for distinct branding and functionality for different target audiences.

---

## 🚀 Key Features

*   **Multi-Flavor Architecture:** A single codebase powers 5 distinct apps (WinIt, Perks, Swag, Codblox, Crypto), reducing maintenance overhead.
*   **Real-time Updates:** Powered by Firebase Firestore for instant code availability.
*   **Push Notifications:** Integrated with Firebase Cloud Messaging (FCM) to alert users of new drops.
*   **Ad Integration:** Monetized via Google AdMob with flavor-specific ad unit configurations.
*   **Secure & Optimized:** Implements best practices for security (obfuscation, key management) and performance.

---

## 🛠️ Technical Architecture: The Power of Flavors

This project leverages **Flutter Flavors** to achieve extreme modularity and automation. Instead of maintaining 5 separate projects, we use a single source of truth.

### How it Works
1.  **Configuration Injection:** Each flavor (`winit`, `perks`, `swag`, etc.) has its own configuration entry point (`main_<flavor>.dart`) which injects specific assets, API endpoints, and UI themes into the app.
2.  **Automated Build Process:**
    *   We utilize specific build commands (e.g., `flutter build appbundle --flavor winit`) to generate separate binaries from the same code.
    *   **Automation:** A batch script (`compila.bat`) automates the sequential building of all flavors, significantly reducing deployment time.
3.  **Dynamic Assets & Branding:** The app dynamically loads logos, drawer headers, and color schemes based on the active flavor at runtime.

### Flavor List
*   **WinIt:** The core codes app.
*   **Perks:** Focused on perk codes.
*   **Swag:** Tailored for Swagbucks users.
*   **Codblox:** Specialized for game codes.
*   **Crypto:** For cryptocurrency related rewards.

---

## 🔧 Development & Setup

### Prerequisites
*   Flutter SDK ^3.8.1
*   Java JDK 11
*   Android Studio / VS Code

### Building a Flavor
To build a specific flavor (e.g., WinIt) for Android:
```bash
flutter build apk --flavor winit -t lib/main_winit.dart
```

### Running Locally
```bash
flutter run --flavor winit -t lib/main_winit.dart
```

---

## 🔒 Security Measures
*   **Keystore Protection:** Signing keys are strictly excluded from version control.
*   **ProGuard/R8:** Code obfuscation is enabled for release builds to reverse engineering harder.
*   **Environment Segregation:** distinct Google Service configurations for each flavor.

---

**Developed by Elliot Barrios**
