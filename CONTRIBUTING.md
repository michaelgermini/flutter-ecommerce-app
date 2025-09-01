# Contributing to Flutter E-Commerce App

Thank you for your interest in contributing to our Flutter E-Commerce App! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Bugs
- Use the GitHub issue tracker
- Provide detailed bug reports including:
  - Steps to reproduce
  - Expected vs actual behavior
  - Device/platform information
  - Screenshots if applicable

### Suggesting Features
- Use the GitHub issue tracker with the "enhancement" label
- Describe the feature and its benefits
- Include mockups or examples if possible

### Code Contributions
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 🏗️ Development Setup

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Setup Steps
1. Fork and clone the repository
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`
4. Ensure all tests pass: `flutter test`

## 📋 Code Style Guidelines

### Dart/Flutter
- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused

### File Organization
```
lib/
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── widgets/         # Reusable widgets
├── utils/           # Utility functions
└── assets/          # Static assets
```

### Naming Conventions
- **Files**: snake_case (e.g., `product_card.dart`)
- **Classes**: PascalCase (e.g., `ProductCard`)
- **Variables**: camelCase (e.g., `productName`)
- **Constants**: SCREAMING_SNAKE_CASE (e.g., `MAX_ITEMS`)

## 🧪 Testing

### Writing Tests
- Write unit tests for business logic
- Write widget tests for UI components
- Write integration tests for user flows
- Aim for good test coverage

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

## 📝 Commit Guidelines

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

### Types
- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples
```
feat(cart): add remove item functionality
fix(ui): resolve navigation bar overflow issue
docs(readme): update installation instructions
```

## 🔄 Pull Request Process

### Before Submitting
1. Ensure your code follows the style guidelines
2. Add tests for new functionality
3. Update documentation if needed
4. Test on multiple platforms (web, Android, iOS)

### Pull Request Template
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
- [ ] Integration tests pass
- [ ] Tested on multiple platforms

## Screenshots
Add screenshots if UI changes are involved

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes
```

## 🎯 Areas for Contribution

### High Priority
- [ ] Backend API integration
- [ ] User authentication
- [ ] Payment gateway integration
- [ ] Performance optimization
- [ ] Accessibility improvements

### Medium Priority
- [ ] Dark mode theme
- [ ] Multi-language support
- [ ] Push notifications
- [ ] Offline support
- [ ] Analytics integration

### Low Priority
- [ ] Additional animations
- [ ] UI theme customization
- [ ] Advanced filtering
- [ ] Social sharing
- [ ] Wishlist functionality

## 🐛 Bug Reports

### Required Information
- **Platform**: Web/Android/iOS/Desktop
- **Flutter Version**: `flutter --version`
- **Steps to Reproduce**: Detailed steps
- **Expected Behavior**: What should happen
- **Actual Behavior**: What actually happens
- **Screenshots**: If applicable

### Bug Report Template
```markdown
## Bug Description
Brief description of the bug

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen

## Actual Behavior
What actually happens

## Environment
- Platform: [Web/Android/iOS/Desktop]
- Flutter Version: [Version]
- Device: [Device/OS]

## Additional Information
Any other relevant information
```

## 💡 Feature Requests

### Required Information
- **Feature Description**: What the feature should do
- **Use Case**: Why this feature is needed
- **Mockups**: Visual examples if applicable
- **Implementation Ideas**: How it could be implemented

### Feature Request Template
```markdown
## Feature Description
Brief description of the feature

## Use Case
Why this feature is needed

## Proposed Implementation
How it could be implemented

## Mockups
Add mockups or examples

## Additional Information
Any other relevant information
```

## 📞 Getting Help

### Communication Channels
- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For general questions
- **Pull Requests**: For code reviews and feedback

### Code of Conduct
- Be respectful and inclusive
- Help others learn and grow
- Provide constructive feedback
- Follow the project's coding standards

## 🏆 Recognition

Contributors will be recognized in:
- Project README
- Release notes
- Contributor hall of fame

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Flutter E-Commerce App! 🚀
