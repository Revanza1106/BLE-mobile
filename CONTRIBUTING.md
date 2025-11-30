# Contributing to BLE Access Control

Thank you for your interest in contributing to BLE Access Control! This guide will help you get started.

## 🚀 Quick Start for Contributors

### Prerequisites

1. **Flutter Setup**: Ensure you have Flutter 3.9.2+ installed
2. **Git Setup**: Configure your Git with name and email
3. **GitHub Account**: Fork the repository to your account

### Development Workflow

1. **Fork & Clone**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/ble_access_control.git
   cd ble_access_control
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **Make Changes** and test thoroughly
5. **Submit Pull Request** with detailed description

## 🏗️ Development Guidelines

### Code Style

We follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines:

- **Use `dart format`** to format your code
- **Use `flutter analyze`** to check for issues
- **Add comments** for complex logic
- **Follow existing naming conventions**

### Code Organization

```
lib/
├── core/           # Core utilities and services
├── models/         # Data models
├── viewmodels/     # State management
└── views/          # UI components
```

### Before Submitting

1. **Run Tests**:
   ```bash
   flutter test
   ```

2. **Check Code Quality**:
   ```bash
   flutter analyze
   dart format .
   ```

3. **Test on Both Platforms** (if possible):
   ```bash
   flutter run -d android
   flutter run -d ios  # macOS only
   ```

## 🐛 Bug Reports

When reporting bugs, please include:

- **Device Information**: OS version, device model
- **App Version**: Version of the app you're using
- **Steps to Reproduce**: Detailed reproduction steps
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Logs**: Any relevant error logs

### Bug Report Template

```markdown
## Bug Description
Brief description of the bug

## Steps to Reproduce
1. Go to...
2. Click on...
3. See error

## Expected Behavior
What you expected to happen

## Actual Behavior
What actually happened

## Device Information
- OS: [e.g. Android 13, iOS 16.1]
- Device: [e.g. Samsung Galaxy S21, iPhone 14]
- App Version: [e.g. 1.0.0]

## Logs
[Include any relevant log output]
```

## 💡 Feature Requests

We welcome feature requests! Please:

1. **Check existing issues** to avoid duplicates
2. **Provide clear description** of the feature
3. **Explain the use case** and why it's valuable
4. **Consider implementation complexity**

### Feature Request Template

```markdown
## Feature Description
Clear description of the proposed feature

## Use Case
Explain why this feature is needed and how it would be used

## Proposed Solution
How you envision this feature working

## Alternatives Considered
Any alternative approaches you've thought about

## Additional Context
Any additional information or context
```

## 🔧 Development Setup

### Environment Setup

1. **Install Flutter**:
   ```bash
   # Follow official guide: https://flutter.dev/docs/get-started/install
   flutter doctor
   ```

2. **Set up IDE**:
   - **VS Code**: Install Flutter and Dart extensions
   - **Android Studio**: Install Flutter plugin

3. **Configure Emulators**:
   ```bash
   flutter emulators  # List available emulators
   flutter emulators --launch <emulator_id>  # Launch specific emulator
   ```

### Project Structure Understanding

- **`core/`**: Shared utilities, services, and constants
- **`models/`**: Data models and business logic
- **`viewmodels/`**: State management using Provider pattern
- **`views/`**: UI components and screens

### Key Dependencies

- **flutter_blue_plus**: BLE communication
- **permission_handler**: Device permissions
- **shared_preferences**: Local storage

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Writing Tests

1. **Unit Tests**: Test individual functions and classes
2. **Widget Tests**: Test UI components
3. **Integration Tests**: Test complete user flows

### Test Structure

```dart
void main() {
  group('ComponentName', () {
    testWidgets('should display correctly', (WidgetTester tester) async {
      // Test implementation
    });
  });
}
```

## 📱 Platform-Specific Guidelines

### Android

- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: Latest stable
- **Permissions**: All BLE and location permissions in AndroidManifest.xml

### iOS

- **Minimum iOS**: 11.0+
- **Bluetooth Info**: Add usage descriptions in Info.plist
- **Location**: Add location usage description for BLE scanning

## 🔄 Pull Request Process

### Before Submitting PR

1. **Create descriptive title** for your PR
2. **Write detailed description** of changes
3. **Link related issues** if applicable
4. **Add screenshots** for UI changes
5. **Ensure tests pass**
6. **Update documentation** if needed

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Manual testing completed

## Screenshots
[Add screenshots for UI changes]

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
```

## 🎯 Current Focus Areas

We're currently focusing on:

- [ ] Improving BLE connection stability
- [ ] Adding more device compatibility
- [ ] Enhanced error handling and user feedback
- [ ] UI/UX improvements
- [ ] Performance optimizations

Check our [Projects](https://github.com/yourusername/ble_access_control/projects) page for current priorities.

## 💬 Getting Help

- **GitHub Issues**: For bug reports and feature requests
- **Discussions**: For general questions and ideas
- **Email**: revanza.firdaus@gmail.com for private matters

## 📄 Code of Conduct

Please be respectful and inclusive in all interactions. We want to maintain a welcoming environment for all contributors.

### Our Pledge

- **Be inclusive** and welcoming to all
- **Be respectful** of different viewpoints and experiences
- **Focus on** what's best for the community
- **Show empathy** towards other community members

## 🙏 Recognition

Contributors are recognized in:

- **README.md**: Contributors section
- **Release notes**: For significant contributions
- **Special thanks** in app about dialog

Thank you for contributing to BLE Access Control! 🎉