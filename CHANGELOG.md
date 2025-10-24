# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-24

### Added
- Initial Flutter project setup for iOS, Android, and Web/PWA
- Firebase backend integration
  - Firebase Authentication with email/password
  - Cloud Firestore for data storage
  - Cloud Storage for media files
  - Firebase Analytics
- Core application structure
  - Home screen for public users
  - Admin backoffice for content management
  - User authentication service
  - Game management service
- Data models
  - User model with admin role support
  - Game model with categories and metadata
- Security configurations
  - Firestore security rules
  - Storage security rules
- CI/CD pipeline
  - GitHub Actions workflow for build and test
  - Automated deployment to Firebase Hosting
  - Multi-platform build support
- Documentation
  - README with project overview
  - SETUP guide with detailed installation steps
  - CONTRIBUTING guidelines
  - ARCHITECTURE documentation
  - LICENSE (MIT)
- Testing infrastructure
  - Unit tests for data models
  - Widget test for main app
  - Code quality workflow
- Platform configurations
  - Android app configuration (SDK 21+)
  - iOS app configuration (iOS 12+)
  - Web/PWA configuration with manifest

### Security
- Implemented Firestore security rules for user data protection
- Implemented Storage security rules for file uploads
- Admin-only access control for game management

## [Unreleased]

### Planned
- Social authentication providers (Google, Apple)
- Push notifications
- In-app purchases
- User profiles and achievements
- Game ratings and reviews
- Advanced search and filtering
- Real-time multiplayer features
- Performance monitoring
- Crash reporting integration
- Internationalization support
- Dark mode theme
