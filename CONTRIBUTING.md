# Contributing to Giro Jogos

Thank you for your interest in contributing to Giro Jogos! This document provides guidelines for contributing to the project.

## Development Setup

1. Fork and clone the repository
2. Install Flutter SDK (3.16.0 or higher)
3. Run `flutter pub get` to install dependencies
4. Configure Firebase using `flutterfire configure`

## Code Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter format .` before committing
- Run `flutter analyze` to check for issues
- All code must pass the linting rules defined in `analysis_options.yaml`

## Commit Messages

- Use clear and descriptive commit messages
- Start with a verb in the present tense (e.g., "Add", "Fix", "Update")
- Keep the first line under 72 characters
- Reference issues when applicable

## Pull Request Process

1. Create a new branch from `develop` for your feature
2. Make your changes following the code style guidelines
3. Add or update tests as needed
4. Ensure all tests pass: `flutter test`
5. Update documentation if you're changing functionality
6. Submit a pull request to the `develop` branch
7. Wait for code review and address any feedback

## Testing

- Write unit tests for new business logic
- Write widget tests for new UI components
- Ensure test coverage remains high
- Run tests with `flutter test`

## Reporting Bugs

- Use the GitHub issue tracker
- Describe the bug clearly
- Include steps to reproduce
- Provide screenshots if applicable
- Include device/platform information

## Feature Requests

- Use the GitHub issue tracker
- Clearly describe the feature
- Explain why it would be useful
- Provide examples if possible

## Questions?

Feel free to open an issue for any questions about contributing.
