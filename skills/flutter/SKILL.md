---
name: Flutter
description: Build performant cross-platform mobile apps with Flutter framework, Dart language, and Flutter ecosystem best practices.
metadata: {"clawdbot":{"emoji":"📱","os":["linux","darwin","win32"]}}
---

# Flutter Skill

## Project Setup

- Use `flutter create` for new projects
- Follow official Flutter project structure (lib/, test/, android/, ios/, web/)
- Use `flutter pub get` to install dependencies
- Keep `pubspec.yaml` clean and version-locked

## Widget Development

- Prefer `StatelessWidget` when possible—simpler, easier to test
- Use `const` constructors—enables widget tree optimizations
- Extract reusable widgets—avoid deep nesting
- Use `Builder` or `LayoutBuilder` for context-dependent layouts
- Avoid rebuilding entire tree—use `const`, keys, and selective updates

## State Management

- Choose Riverpod for new projects—type-safe, testable, no BuildContext needed
- Use `StateNotifier` for complex state—immutable state, clear mutations
- Avoid `setState` in large trees—lift state up or use proper state management
- Use `select()` to watch only what you need—prevents unnecessary rebuilds
- Dispose resources properly—streams, controllers, listeners

## Navigation

- Use GoRouter for declarative routing—deep linking, type safety
- Pass minimal data between screens—prefer IDs over objects
- Handle back button properly—Android expectations
- Use Hero animations sparingly—can hurt performance
- Deep linking from day one—marketing, sharing need it

## Performance

- Use `ListView.builder` for long lists—lazy loading, memory efficient
- Image caching with `cached_network_image`—don't reload images
- Debounce rapid user actions—search input, button clicks
- Use `const` where possible—compile-time constants
- Profile with Flutter DevTools—find real bottlenecks, not guesses

## Platform Integration

- Use platform channels sparingly—prefer plugins
- Handle permissions gracefully—explain why you need them
- Test on real devices—not just simulators
- Platform-specific UI when needed—follow platform conventions
- Background execution: declare in manifest, handle battery optimization

## Testing

- Unit tests for business logic—fast, isolated
- Widget tests for UI components—test rendering, interactions
- Integration tests for critical flows—end-to-end
- Mock external dependencies—tests should be deterministic
- Coverage > 80%—focus on critical paths

## Common Commands

```bash
flutter doctor          # Check environment
flutter create <name>   # Create new project
flutter run             # Run on connected device
flutter build apk       # Build Android APK
flutter build ios       # Build iOS app
flutter test            # Run tests
flutter pub get         # Install dependencies
flutter pub upgrade     # Upgrade dependencies
```