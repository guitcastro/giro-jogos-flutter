# Architecture Documentation

## Overview

Giro Jogos is a cross-platform gaming application built with Flutter, following clean architecture principles and best practices for scalable mobile and web development.

## Technology Stack

### Frontend
- **Flutter 3.16+**: Cross-platform UI framework
- **Dart 3.0+**: Programming language
- **Provider**: State management
- **GoRouter**: Declarative routing

### Backend
- **Firebase**: Backend-as-a-Service platform
  - **Firebase Auth**: User authentication
  - **Cloud Firestore**: NoSQL database
  - **Cloud Storage**: File storage
  - **Firebase Analytics**: App analytics
  - **Firebase Hosting**: Web hosting

### CI/CD
- **GitHub Actions**: Automated workflows
- **Firebase Hosting**: Automated deployment

## Project Structure

```
lib/
├── main.dart                    # Application entry point
├── firebase_options.dart        # Firebase configuration
└── src/
    ├── app.dart                # Main app widget with routing
    ├── constants.dart          # App-wide constants
    ├── models/                 # Data models
    │   ├── user.dart
    │   └── game.dart
    ├── services/               # Business logic
    │   ├── auth_service.dart
    │   └── game_service.dart
    ├── screens/                # UI screens
    │   ├── home/
    │   │   └── home_screen.dart
    │   └── admin/
    │       └── admin_screen.dart
    └── widgets/                # Reusable widgets
```

## Architecture Patterns

### Clean Architecture Layers

1. **Presentation Layer** (`screens/`, `widgets/`)
   - UI components
   - User interaction handling
   - State consumption

2. **Business Logic Layer** (`services/`)
   - Application logic
   - State management
   - Service coordination

3. **Data Layer** (`models/`)
   - Data models
   - Repository pattern (via services)
   - Data transformation

### State Management

The app uses **Provider** for state management:

- **AuthService**: Manages authentication state
- **GameService**: Manages game data operations
- Scoped providers for feature-specific state

### Routing

**GoRouter** provides:
- Declarative routing
- Deep linking support
- Route guards (planned for auth)
- Type-safe navigation

## Firebase Integration

### Authentication Flow

1. User signs up/in via email/password
2. Firebase Auth creates/authenticates user
3. AuthService updates app state
4. UI reflects authentication status

### Firestore Structure

```
firestore/
├── users/
│   └── {userId}/
│       ├── email: string
│       ├── displayName: string
│       ├── isAdmin: boolean
│       └── createdAt: timestamp
└── games/
    └── {gameId}/
        ├── title: string
        ├── description: string
        ├── imageUrl: string
        ├── categories: array
        ├── isActive: boolean
        ├── createdAt: timestamp
        └── updatedAt: timestamp
```

### Security Rules

**Firestore Rules:**
- Users can read/write their own data
- Games are publicly readable
- Only admins can write to games collection

**Storage Rules:**
- Authenticated users can upload to their folders
- All uploads are publicly readable
- Admins have broader upload permissions

## Platform-Specific Considerations

### Android
- Min SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Multi-dex enabled for Firebase
- Material Design 3

### iOS
- Min iOS: 12.0
- CocoaPods for dependencies
- Swift-based AppDelegate
- Adaptive icons

### Web/PWA
- Progressive Web App support
- Service Worker for offline functionality
- Manifest for installability
- Firebase Hosting

## Development Workflow

### Local Development

1. Clone repository
2. Run `flutter pub get`
3. Configure Firebase with `flutterfire configure`
4. Run on desired platform: `flutter run -d <device>`

### Testing Strategy

- **Unit Tests**: Model and service logic
- **Widget Tests**: UI components
- **Integration Tests**: End-to-end flows (planned)

### Code Quality

- **Linting**: `flutter analyze` with strict rules
- **Formatting**: `flutter format` with consistent style
- **Type Safety**: Full null safety enabled

## CI/CD Pipeline

### On Pull Request
1. Code formatting check
2. Static analysis
3. Unit tests with coverage
4. Build verification (Android, iOS, Web)

### On Main Branch Push
1. All PR checks
2. Build release artifacts
3. Deploy web to Firebase Hosting

## Security Considerations

- Firebase security rules enforce data access
- Authentication required for sensitive operations
- Admin privileges checked server-side
- Environment variables for sensitive config
- HTTPS for all web communication

## Performance Optimization

- Lazy loading of game lists
- Image caching and optimization
- Firestore query indexes
- Code splitting for web
- Platform-specific optimizations

## Future Enhancements

### Planned Features
- [ ] Social authentication (Google, Apple)
- [ ] Real-time multiplayer support
- [ ] Push notifications
- [ ] In-app purchases
- [ ] User profiles and achievements
- [ ] Game ratings and reviews
- [ ] Search and filtering
- [ ] Advanced admin dashboard

### Technical Improvements
- [ ] Integration testing suite
- [ ] Performance monitoring
- [ ] Error tracking (Sentry/Crashlytics)
- [ ] A/B testing framework
- [ ] Localization/internationalization
- [ ] Accessibility improvements
- [ ] Dark mode support

## Deployment

### Web/PWA
Deployed automatically via GitHub Actions to Firebase Hosting on main branch pushes.

### Mobile Apps

**Android:**
1. Build: `flutter build appbundle --release`
2. Sign with keystore
3. Upload to Google Play Console

**iOS:**
1. Build: `flutter build ios --release`
2. Archive in Xcode
3. Submit to App Store Connect

## Monitoring and Analytics

- Firebase Analytics for user behavior
- Performance monitoring (planned)
- Crash reporting (planned)
- Custom events for key actions

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## License

MIT License - see [LICENSE](LICENSE) file.
