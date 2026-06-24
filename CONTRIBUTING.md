# Contributing to RiderMate

Thank you for your interest in contributing to RiderMate! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Branch Naming Conventions](#branch-naming-conventions)

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

## Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.10.1 or higher
- **Dart SDK**: Version 3.0.0 or higher
- **Git**: For version control
- **Android Studio** or **VS Code**: Recommended IDEs
- **Android SDK** (for Android development)
- **Xcode** (for iOS development, macOS only)

### Setting Up Development Environment

1. **Clone the repository**
   ```bash
   git clone https://github.com/rithwikkr0/Ridermate.git
   cd Ridermate
   ```

2. **Navigate to the app directory**
   ```bash
   cd ridermate_app
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Verify setup**
   ```bash
   flutter doctor
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Development Workflow

### 1. Fork and Clone

Fork the repository on GitHub and clone your fork locally.

```bash
git clone https://github.com/YOUR_USERNAME/Ridermate.git
cd Ridermate
git remote add upstream https://github.com/rithwikkr0/Ridermate.git
```

### 2. Create a Feature Branch

Always create a new branch for your work:

```bash
git checkout -b feature/your-feature-name
```

See [Branch Naming Conventions](#branch-naming-conventions) for naming guidelines.

### 3. Make Your Changes

- Write clean, readable code
- Follow the coding standards
- Add tests for new features
- Update documentation as needed

### 4. Test Your Changes

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/ride_history_test.dart

# Run tests with coverage
flutter test --coverage
```

### 5. Commit Your Changes

Follow the [Commit Message Guidelines](#commit-message-guidelines).

```bash
git add .
git commit -m "feat: add new feature description"
```

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

## Coding Standards

### Dart/Flutter Style Guide

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

#### Key Points:

1. **Formatting**
   ```bash
   # Format your code before committing
   flutter format lib/ test/
   ```

2. **Naming Conventions**
   - Classes: `PascalCase` (e.g., `RideHistory`)
   - Variables/Functions: `camelCase` (e.g., `calculateSpeed`)
   - Constants: `lowerCamelCase` (e.g., `defaultSpeed`)
   - Private members: prefix with `_` (e.g., `_privateMethod`)

3. **File Organization**
   ```
   lib/
   ├── models/          # Data models
   ├── screens/         # UI screens
   ├── widgets/         # Reusable widgets
   ├── services/        # Business logic
   ├── utils/           # Utility functions
   └── main.dart        # Entry point
   ```

4. **Code Documentation**
   ```dart
   /// Calculate the distance between two GPS coordinates.
   ///
   /// Uses the Haversine formula to calculate the great-circle distance.
   ///
   /// Parameters:
   /// - [lat1]: Latitude of the first point
   /// - [lon1]: Longitude of the first point
   /// - [lat2]: Latitude of the second point
   /// - [lon2]: Longitude of the second point
   ///
   /// Returns the distance in kilometers.
   double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
     // Implementation
   }
   ```

### Linting

The project uses `flutter_lints`. Run the linter:

```bash
flutter analyze
```

Fix all warnings and errors before submitting a pull request.

## Testing Requirements

All contributions must include appropriate tests:

### Unit Tests

- Required for all business logic
- Required for utility functions
- Required for data models
- Minimum coverage: **80%**

```dart
// Example unit test
test('should calculate distance correctly', () {
  // Arrange
  final calculator = DistanceCalculator();
  
  // Act
  final result = calculator.calculate(0, 0, 1, 1);
  
  // Assert
  expect(result, greaterThan(0));
});
```

### Widget Tests

- Required for all custom widgets
- Required for screen components
- Test user interactions

```dart
// Example widget test
testWidgets('should display ride button', (WidgetTester tester) async {
  await tester.pumpWidget(MyWidget());
  expect(find.text('START RIDE'), findsOneWidget);
});
```

### Integration Tests

- Required for critical user flows
- Use `integration_test` package

### Running Tests

```bash
# All tests
flutter test

# With coverage report
flutter test --coverage

# Specific test file
flutter test test/models/ride_history_test.dart

# Integration tests
flutter test integration_test/
```

### Coverage Requirements

- **Unit tests**: Minimum 80% coverage
- **Widget tests**: Cover all user-facing components
- **Integration tests**: Cover critical user journeys

## Documentation

### Code Documentation

- Add dartdoc comments to all public APIs
- Include usage examples for complex functions
- Document all parameters and return values

### README Updates

Update README.md if you:
- Add new features
- Change installation steps
- Modify dependencies
- Update system requirements

### Architecture Documentation

Update architecture docs in `docs/` if you:
- Add new modules
- Change system design
- Modify data flow
- Update integrations

## Pull Request Process

### Before Submitting

1. ✅ All tests pass
2. ✅ Code is formatted (`flutter format`)
3. ✅ No linting errors (`flutter analyze`)
4. ✅ Documentation is updated
5. ✅ Coverage meets requirements
6. ✅ PR description is complete

### PR Template

Use the [Pull Request Template](.github/pull_request_template.md):

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests added/updated
- [ ] All tests passing

## Checklist
- [ ] Code formatted
- [ ] Linting passed
- [ ] Documentation updated
- [ ] Self-reviewed
```

### Review Process

1. Automated checks must pass
2. At least one code review approval required
3. All review comments must be addressed
4. Maintain a clean commit history

### After Approval

- Squash commits if requested
- Ensure branch is up to date with main
- Maintainer will merge the PR

## Commit Message Guidelines

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semi colons, etc)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `build`: Build system changes
- `ci`: CI/CD changes
- `chore`: Other changes (dependencies, etc)

### Examples

```bash
# Feature
feat(ride): add GPS tracking functionality

# Bug fix
fix(memory): resolve crash when saving memory without image

# Documentation
docs(readme): update installation instructions

# Test
test(models): add unit tests for RideHistory model

# Breaking change
feat(api)!: change ride data structure

BREAKING CHANGE: RideHistory now requires userId parameter
```

### Scope

Use these scopes when applicable:
- `ride`: Ride tracking features
- `memory`: Memory features
- `profile`: User profile
- `auth`: Authentication
- `ui`: User interface
- `test`: Testing
- `docs`: Documentation
- `ci`: CI/CD

## Branch Naming Conventions

### Format

```
<type>/<short-description>
```

### Types

- `feature/`: New features
- `bugfix/`: Bug fixes
- `hotfix/`: Urgent fixes for production
- `refactor/`: Code refactoring
- `docs/`: Documentation changes
- `test/`: Test additions/changes

### Examples

```bash
feature/gps-tracking
bugfix/memory-crash
hotfix/login-error
refactor/ride-service
docs/api-documentation
test/add-unit-tests
```

### Rules

- Use lowercase
- Use hyphens to separate words
- Be descriptive but concise
- Include issue number if applicable: `feature/123-gps-tracking`

## Issue Guidelines

### Creating Issues

When creating an issue, please:

1. Use a clear, descriptive title
2. Provide detailed description
3. Include steps to reproduce (for bugs)
4. Add relevant labels
5. Include screenshots/logs if applicable

### Issue Labels

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Documentation improvements
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention needed
- `question`: Further information requested
- `wontfix`: Won't be worked on

## Getting Help

- 📖 Read the [README](README.md)
- 📚 Check the [documentation](docs/)
- 💬 Ask questions in GitHub Discussions
- 🐛 Report bugs via GitHub Issues

## Recognition

Contributors will be recognized in:
- Contributors section of README
- Release notes
- Project documentation

Thank you for contributing to RiderMate! 🚴‍♂️
