# BLE Access Control

A Flutter-based mobile application for controlling smart door locks via Bluetooth Low Energy (BLE). This project provides a user-friendly interface for configuring and managing access control systems.

## 🚀 Features

- **Bluetooth LE Connectivity**: Seamless connection to BLE-enabled door locks
- **Real-time Status**: Live monitoring of door lock status and connection state
- **Secure Communication**: Encrypted command transmission between app and device
- **Device Configuration**: Easy setup and management of paired devices
- **Dark Theme**: Modern dark mode UI with intuitive navigation
- **Settings Management**: Store and manage device credentials and preferences
- **Cross-platform**: Works on both Android and iOS devices

## 📱 Screenshots

_*(Add screenshots of your app in action here)*_

## 🛠️ Requirements

### System Requirements

- **Flutter**: 3.9.2 or higher
- **Dart SDK**: 3.9.2 or higher
- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 11.0+

### Hardware Requirements

- Bluetooth Low Energy (BLE) capable smartphone
- BLE-enabled smart door lock compatible with the app's communication protocol

### Dependencies

- `flutter_blue_plus`: ^1.9.0 - Bluetooth LE communication
- `permission_handler`: ^11.0.0 - Runtime permissions management
- `shared_preferences`: ^2.2.2 - Local data storage
- `cupertino_icons`: ^1.0.8 - iOS-style icons

## 🚀 Getting Started

### Prerequisites

1. **Install Flutter**:
   ```bash
   # Follow the official guide at https://flutter.dev/docs/get-started/install
   flutter doctor
   ```

2. **Set up development environment**:
   - Android Studio with Android SDK
   - Xcode (for iOS development on macOS)
   - VS Code with Flutter extensions (alternative)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/ble_access_control.git
   cd ble_access_control
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure permissions**:

   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.BLUETOOTH" />
   <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   <uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation" />
   <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
   <uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
   ```

   **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSBluetoothAlwaysUsageDescription</key>
   <string>This app needs Bluetooth access to control smart door locks</string>
   <key>NSBluetoothPeripheralUsageDescription</key>
   <string>This app needs Bluetooth access to control smart door locks</string>
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs location access to discover Bluetooth devices</string>
   ```

4. **Run the app**:
   ```bash
   # For development
   flutter run

   # For production build
   flutter build apk          # Android APK
   flutter build ios          # iOS build
   ```

## ⚙️ Configuration

### BLE Device Configuration

The app communicates with BLE devices using specific UUIDs. Configure these in `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String serviceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String controlUuid = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  static const String serialUuid = "a1b2c3d4-5678-90ab-cdef-1234567890ab";
}
```

### Command Protocol

The app uses a command-based communication protocol:

- **Command Format**: `SECRET|DEVICE_SERIAL|COMMAND`
- **Supported Commands**:
  - `LOCK` - Lock the door
  - `RELEASE` - Unlock the door
  - `ALWAYS_ON` - Set door to always unlocked mode

## 🏗️ Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart      # App-wide constants and configurations
│   ├── services/
│   │   ├── bluetooth_service.dart  # BLE communication layer
│   │   ├── notification_service.dart # UI notifications and dialogs
│   │   └── storage_service.dart    # Local data persistence
│   └── utils/
│       ├── error_handler.dart      # Error management and logging
│       ├── logger.dart             # Comprehensive logging system
│       └── debug_helper.dart       # Debug utilities
├── models/
│   ├── bluetooth_device_info.dart  # BLE device data model
│   └── door_state.dart            # Door lock state management
├── viewmodels/
│   ├── door_viewmodel.dart        # Main door control logic
│   └── settings_viewmodel.dart    # Settings management
└── views/
    ├── home_view.dart             # Main user interface
    └── settings_view.dart          # Configuration and settings
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Development Setup

1. **Fork the repository**
2. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes** and follow the code style:
   - Use `flutter analyze` to check for issues
   - Run `flutter test` before submitting
   - Follow the existing coding conventions

4. **Test thoroughly**:
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit your changes**:
   ```bash
   git commit -m "feat: add your feature description"
   ```

6. **Push to your fork** and create a pull request

### Code Style Guidelines

- Follow effective dart guidelines
- Use meaningful variable and function names
- Add appropriate comments for complex logic
- Ensure proper error handling throughout the app

## 🐛 Troubleshooting

### Common Issues

1. **Bluetooth not working**:
   - Ensure Bluetooth is enabled on your device
   - Check that location permissions are granted (required for BLE scanning on Android)
   - Verify that your BLE device is advertising correctly

2. **Build failures**:
   ```bash
   flutter clean
   flutter pub get
   flutter doctor  # Check for environment issues
   ```

3. **Connection issues**:
   - Check if the device is within range
   - Verify the UUIDs match your hardware configuration
   - Ensure the device is not already connected to another app

4. **Permission denied errors**:
   - Go to Settings > Apps > [Your App] > Permissions
   - Grant all required permissions (Bluetooth, Location)

### Debug Mode

Enable debug logging by setting `DebugHelper.setDebugMode(true)` in `main.dart`. This will provide detailed logs for troubleshooting.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - Cross-platform development framework
- [flutter_blue_plus](https://pub.dev/packages/flutter_blue_plus) - BLE communication library
- The Flutter community for excellent packages and support

## 📞 Support

- 📧 Email: revanza.firdaus@gmail.com.com
- 🐛 Issues: [GitHub Issues](https://github.com/Revanza1106/BLE-mobile/issues)

---

**Built with ❤️**
