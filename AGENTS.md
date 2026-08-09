# Repository Guidelines

## Project Structure & Module Organization

`Activity/` contains the SwiftUI app. Keep primary screens in `Activity/MainFile/`, app-only state and services in `Activity/Shared/`, and models in `Activity/Model/`. Shared Live Activity contracts and utilities live in the root `Shared/` directory; changes to `IslandAttributes` must remain compatible with both the app and widget extension.

`WidgetForActivity/` renders the lock-screen and Dynamic Island experience. `AppIntentsForActivity/` hosts the App Intents extension, while the main app's shortcut implementations are in `Activity/MainFile/AppIntentManager.swift`. `ShareForActivity/` is the UIKit share extension. Assets belong in the target-specific `.xcassets` catalog. Tests are in `ActivityTests/` and `ActivityUITests/`.

## Build, Test, and Development Commands

Use Xcode to run the `Activity` scheme on an iPhone simulator or device; Live Activities and Dynamic Island layouts need device/simulator verification.

```sh
xcodebuild -list -project Activity.xcodeproj
xcodebuild -project Activity.xcodeproj -scheme Activity \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

The first command lists targets and schemes. The second builds and runs unit and UI tests. Use a locally installed simulator name; do not commit `DerivedData` or `xcuserdata` changes.

## Coding Style & Naming Conventions

Use Swift 5, four-space indentation, and Xcode's standard formatting. Prefer SwiftUI value views and `@Observable` state for UI state. Name types in `UpperCamelCase`, methods/properties in `lowerCamelCase`, and keep file names aligned with their primary type (for example, `LiveActivityManager.swift`). Keep UI strings localizable through `Localizable.xcstrings`; avoid adding hard-coded user-facing strings without a localization entry.

## Testing Guidelines

Write XCTest unit tests in `ActivityTests/` and UI flows in `ActivityUITests/`. Use descriptive `test...` names, such as `testStartingActivityStoresCurrentActivity()`. Cover behavior that crosses targets—especially the `IslandAttributes.ContentState` contract, notification scheduling, and App Intent behavior. Before opening a PR, run the relevant tests and manually inspect lock-screen, compact, minimal, and expanded Live Activity states.

## Commit & Pull Request Guidelines

This checkout has no Git history, so no repository-specific commit convention is available. Use concise imperative subjects, such as `Fix notification interval refresh`. Keep each commit focused. PRs should explain user-visible behavior, list affected targets, link an issue when available, include simulator screenshots for UI or widget changes, and state the build/test command and result.

## Configuration Notes

Keep bundle identifiers, App Group values, URL schemes, entitlements, and target membership aligned across the app and extensions. Treat signing profiles and any future service credentials as local configuration; never commit secrets.
