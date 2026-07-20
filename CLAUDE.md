# CLAUDE.md — Infiniti Apps Monorepo

## Project Overview

This is a Flutter/Dart monorepo managed with Melos. It contains a suite of personal Android apps built for privacy, local-first storage, and zero telemetry. The developer (InfinitiWarrior) is replacing third-party apps on a Samsung Android phone to reduce tracking, background battery drain, and dependency on closed-source software.

Every app shares a common `core` package for theming, encrypted local storage, shared widgets, and utilities. Each app compiles independently, requests only the permissions it needs, and stores data locally unless explicitly stated otherwise.

## Developer Environment

- OS: Arch Linux with Hyprland (Wayland compositor)
- Shell: zsh
- Editor: assume terminal-based workflow
- Phone: Samsung Android (USB debugging enabled)
- Testing: primary iteration via `flutter run -d linux`, final testing on physical device via USB
- Version control: Git, developer uses Obsidian with git pull/push via Termux on phone
- Package manager: yay/paru for AUR packages

## Tech Stack

- Language: Dart
- Framework: Flutter
- Monorepo tool: Melos (by Invertase) — used for `melos run` scripts (analyze/test/format) only. Dependency resolution uses native **Dart/Flutter pub workspaces**, not `melos bootstrap`/symlinks (see "Monorepo Wiring" below).
- Local database: Drift (formerly Moor) — SQLite abstraction for Dart
- Encrypted storage: flutter_secure_storage
- State management: decide per-app, prefer Riverpod or simple ValueNotifier/ChangeNotifier for small apps
- Audio: just_audio, on_audio_query (music player), record (voice recorder)
- Networking: http or dio
- UI: Material 3 with custom dark theme defined in core

## Project Structure

```
infiniti_apps/
├── melos.yaml
├── pubspec.yaml                ← workspace root (see "Monorepo Wiring")
├── CLAUDE.md                   ← you are here
├── .gitignore                  ← ONLY .gitignore in the repo, see "Monorepo Wiring"
├── packages/
│   ├── core/                   ← shared theme, colors, widgets, storage, utilities
│   │   ├── lib/
│   │   │   ├── theme/          ← dark theme, color scheme, text styles
│   │   │   ├── storage/        ← encrypted local storage, drift database helpers
│   │   │   ├── widgets/        ← shared UI components (buttons, cards, app bar, etc.)
│   │   │   └── utils/          ← common utilities, extensions, helpers
│   │   └── pubspec.yaml
│   ├── app_calculator/         ← app 1  [DONE]
│   ├── app_voice_recorder/     ← app 2  [DONE]
│   ├── app_rss_reader/         ← app 3  [DONE]
│   ├── app_nfc_toolkit/        ← app 4  [next up]
│   ├── app_network_tools/      ← app 5
│   ├── app_file_share/         ← app 6
│   ├── app_music_player/       ← app 7 (capstone, most complex)
│   ├── app_[tbd_1]/            ← app 8 (to be decided)
│   └── app_[tbd_2]/            ← app 9 (to be decided)
```

## App Details

### 1. Calculator (`app_calculator`) — DONE
- Pure logic and UI, no permissions needed
- Scientific functions using `math_expressions` (`ShuntingYardParser`)
- Standard mode: arithmetic, scientific functions, history stored locally (Drift)
- Programmer mode: hex/oct/dec/bin with live base conversion, bitwise ops (AND/OR/XOR/shifts), selectable word size (8/16/32/64-bit), backed by `BigInt` throughout (plain `int` can't hold unsigned 64-bit range)
- Unit converter mode: length, mass, temperature, volume, area, speed, time, digital storage
- Mode switching via a drawer (`ModeDrawer`)
- Priority: FIRST app to build, establishes patterns for the rest

### 2. Voice Recorder (`app_voice_recorder`) — DONE
- Permissions: microphone only (mic permission gated via `record`'s own `hasPermission()`, not `permission_handler` — see "Established Patterns")
- Uses `record` package for audio capture, `just_audio` for playback
- Local file storage only, no cloud — files under `<documentsDir>/recordings/`
- Features: record, pause, resume, stop, playback, rename, delete, format choice (AAC/WAV) in settings
- Metadata (filename, display name, format, duration, created date) in Drift

### 3. RSS Reader (`app_rss_reader`) — DONE
- Permissions: network
- RSS 2.0/Atom parsing with `dart_rss`
- Local database with Drift for subscriptions and cached articles
- Best-effort background refresh via `workmanager` (Android/iOS only — no Linux implementation, guarded off there)
- Features: add/remove feeds, categorize, mark read/unread, offline article cache (HTML stripped to readable text), pull-to-refresh, open original article in browser
- Design goal: replace passive algorithmic scrolling with intentional consumption

### 4. NFC Toolkit (`app_nfc_toolkit`)
- Permissions: NFC
- Uses `nfc_manager` package
- Read, write, format, dump tag data
- IMPORTANT: UID cloning is a hardware limitation on Android phones. The NFC controller has a fixed UID. This app CANNOT spoof/clone UIDs like a Flipper Zero. Do not attempt to implement UID cloning. Focus on data read/write/format/dump.
- Features: read tag info, write NDEF records, format tags, hex dump, save tag data locally

### 5. Network Tools (`app_network_tools`)
- Permissions: network
- Features: ping (dart_ping), traceroute, port scanner, DNS lookup, subnet calculator, whois lookup
- Useful alongside developer's Unifi network setup
- All results stored locally in history

### 6. Local Network File Share (`app_file_share`)
- Permissions: network, storage
- mDNS discovery between phone and Arch/Hyprland desktop
- Direct TCP file transfer, no cloud intermediary
- Companion daemon needed on desktop side (Python or Rust, separate repo or script in this repo)
- KDE Connect protocol is open source and worth referencing for implementation ideas

### 7. Music Player + Downloader (`app_music_player`)
- Permissions: network, storage, notifications (for background playback)
- CAPSTONE PROJECT — build last, most complex
- Local music library playback with `just_audio` and `on_audio_query`
- Downloader for offline copies from YouTube/Spotify (user has paid Spotify subscription, personal use only)
- Spotify-inspired UI: playlists, queue, search, album art, now-playing bar
- Metadata parsing (ID3 tags)
- Background playback with notification controls
- Downloads stored as MP3 locally

### 8. TBD App 1
- Not yet decided. Possible candidates: expense tracker, flashcard/spaced repetition app, or weather app.

### 9. TBD App 2
- Not yet decided.

## Core Package (`packages/core/`)

The core package is the shared foundation. Every app depends on it. It contains:

### Theme (`core/lib/theme/`)
- Dark theme only (matches developer's Hyprland aesthetic), Catppuccin Mocha-inspired palette (mauve primary `#CBA6F7`, base `#1E1E2E`)
- Material 3 color scheme, `AppTheme.dark`
- Custom text styles, consistent spacing (`AppSpacing`), border radius, elevation values
- All colors defined as constants so they're easy to tweak globally

### Storage (`core/lib/storage/`)
- `openAppConnection(String fileName)` — shared Drift `LazyDatabase` helper (`NativeDatabase.createInBackground` + `sqlite3_flutter_libs`); each app's database class wraps this and adds its own tables
- `SecureStorageService` — wraps `flutter_secure_storage` for sensitive key-value pairs
- `AppPaths` — documents/support directory + database path helpers via `path_provider`

### Widgets (`core/lib/widgets/`)
- `InfinitiAppBar` — common app bar with consistent styling
- `AppCard`, `LoadingIndicator`, `EmptyState`
- `SettingsPage`/`SettingsSection` — every app should have a settings page built on this

### Utils (`core/lib/utils/`)
- `AppLogger` (no `print()` in production)
- Date/time formatting, file size formatting, String/DateTime extensions
- `PermissionHelpers` wraps `permission_handler` — **only use this for permissions `permission_handler` actually supports on the target platforms**. It has no Linux implementation; for anything tested on Linux desktop, prefer the underlying plugin's own permission check if it has one (see "Established Patterns").

## Coding Conventions

- Use trailing commas on all argument lists (Dart formatter handles the rest)
- Prefer `const` constructors wherever possible
- File naming: snake_case (Dart convention)
- Class naming: PascalCase
- One widget per file for anything nontrivial
- Keep business logic out of widget build methods; use separate controller/service classes
- Error handling: never silently swallow exceptions, always log or surface to UI
- No print() in production; use `AppLogger` from core
- All user-facing strings should be in one place per app for potential future localization
- No hardcoded colors or text styles outside of core/theme

## Monorepo Wiring

- **Dependency resolution uses native pub workspaces**, not `melos bootstrap`. The root `pubspec.yaml` declares `workspace: [packages/core, packages/app_x, ...]`; every member package sets `resolution: workspace` under its `environment:` key. There is a single shared `pubspec.lock` at the repo root. Run `flutter pub get` from the repo root (or any member) to resolve everything. `melos.yaml` is only used for its `melos run <script>` conveniences (`analyze`, `test`, `format`) via `melos exec`.
- **New app checklist:**
  1. `flutter create --org com.infinitiwarrior --project-name app_x packages/app_x` (or copy an existing `app_*` and rename)
  2. Add it to the root `pubspec.yaml` `workspace:` list
  3. In the new package's `pubspec.yaml`: add `resolution: workspace` under `environment:`, add `core: {path: ../core}` dependency
  4. Set unique `applicationId`/bundle id/`APPLICATION_ID` to `com.infinitiwarrior.<shortname>` across Android/iOS/Linux (default `com.example.*` would collide across apps installed on the same phone)
  5. Set the platform window/app label (Android manifest `android:label`, Linux `my_application.cc` window title) to the human-readable app name
  6. Delete `macos/`, `web/`, `windows/` platform dirs (not targeted) and any nested `.gitignore` `flutter create` generates (see below)
  7. `analysis_options.yaml` in the new package should just be `include: ../../analysis_options.yaml`
  8. Run `flutter pub get` from repo root, then `flutter analyze` and `flutter test` from the new package

- **Root-only `.gitignore` policy**: there is exactly one `.gitignore`, at the repo root. It uses recursive glob prefixes (`**/android/...`, `**/ios/...`, `**/linux/...`) to cover every package's platform build artifacts, instead of each package/platform dir carrying its own `.gitignore`. When scaffolding a new app, delete whatever nested `.gitignore` files `flutter create` generates rather than keeping them.

## Established Patterns (learned building apps 1–2)

These are things that cost real debugging time — apply them proactively in new apps rather than rediscovering them.

- **Drift + `flutter_test` hang/timer issue**: `StreamQueryStore` schedules an internal `Timer.run()` when a stream's last subscriber unsubscribes. If a widget test exercises a Drift stream (e.g. via `StreamBuilder`), you must `await database.close();` **explicitly inside the test body itself** — not only via `addTearDown` — or you'll hit "A Timer is still pending even after the widget tree was disposed". `addTearDown` runs too late relative to `flutter_test`'s pending-timer check. Every app's Drift database class should expose a `.forTesting(super.executor)` constructor so tests can pass `NativeDatabase.memory()`.
- **Never instantiate real platform-plugin wrappers as eager field initializers in a `StatefulWidget`.** Plugins like `record`/`just_audio` set up platform channels on construction, which hangs indefinitely under `flutter_test` with no mocks. Instead: define an abstract service interface (e.g. `AudioRecorderService`), a concrete `Platform*` implementation wrapping the real plugin, inject it via an **optional constructor parameter** defaulting to the platform implementation, and supply a fake implementing the interface in tests. (Note: this forces the widget's constructor to be non-`const`, since a `const` constructor's initializer list can't call a non-const constructor as a default.)
- **Permissions**: prefer a plugin's own built-in permission check over `permission_handler` when the plugin has cross-platform-safe handling and `permission_handler` doesn't support the target platform. Example: `record`'s `AudioRecorder.hasPermission()` handles the native Android prompt itself and returns `true` unconditionally on Linux; `permission_handler` throws `MissingPluginException` on Linux since it has no desktop implementation there. Only reach for `core`'s `PermissionHelpers` when the permission is one `permission_handler` actually supports everywhere you test.
- **`const` map/object literals can't hold closures.** If a factory (e.g. a `Unit.linear()` conversion factory) captures/returns a closure, the containing top-level collection must be `final`, not `const`.
- **`BigInt`, not `int`, for anything claiming to represent unsigned 64-bit values** (e.g. the programmer calculator's qword mode) — Dart's native `int` is signed 64-bit and can't represent the top half of the unsigned range.
- **Widget test gotchas**: (a) a `Key` placed directly on a `Text` widget can't be found via `find.descendant(of: find.byKey(...), matching: find.text(...))` — it isn't its own descendant; read `tester.widget<Text>(find.byKey(...)).data` instead. (b) insert `await tester.pump();` between sequential `tester.tap(...)` calls — gesture recognition needs a frame boundary between interactions or later taps in the sequence won't register.
- **Screenshot hygiene when demoing on Hyprland**: never take a full-desktop screenshot. Query the specific window's geometry first (`hyprctl clients -j`) and crop tightly with `grim -g "x,y WxH"`. A full-desktop shot risks capturing unrelated sensitive windows.
- **Never create a Drift `Stream` (`.watch()`, including joined/`selectOnly` queries) inline inside a widget's `build()` method.** A fresh `Stream` object is created on every rebuild; `StreamBuilder` sees a new `stream:` instance and cancels+resubscribes every time. Plain `select(...).watch()` queries survive this via drift's internal key-based cache (`StreamQueryStore` dedupes by SQL text+args and reuses the underlying stream), but **joined selects and aggregate (`selectOnly`) queries are not key-cached** — every inline call spawns a brand-new, uncached `QueryStream` whose old instance is abandoned mid-teardown. In a widget test that then calls `await database.close()`, this reliably **deadlocks** `close()` forever (not just a "pending timer" warning — a genuine hang with zero CPU activity). Fix: cache the `Stream` as a field (`late final` in a `StatefulWidget`'s state, initialized once in `initState`/updated only when its query parameters actually change) instead of calling the `watch()`-returning method directly in `build()`. For streams created per-list-item (e.g. one per row in a `ListView.builder`), extract a small `StatefulWidget` for the row with a stable `ValueKey` (e.g. the row's id) so its state — and thus its cached stream — survives list rebuilds instead of being recreated each frame.

## Build and Run

```bash
# Resolve dependencies for the whole workspace (run from repo root)
flutter pub get

# Run a specific app on Linux (fast iteration)
cd packages/app_calculator
flutter run -d linux

# Run on connected Android device
cd packages/app_calculator
flutter run

# Run all tests / analyze all packages (via melos exec)
melos run test
melos run analyze
melos run format
```

## Important Notes

- This is a personal project. No CI/CD pipeline needed unless the developer adds one.
- All data stays local. No analytics, no telemetry, no crash reporting services.
- No Firebase, no Google services dependencies.
- When adding a new app, follow the "Monorepo Wiring" checklist above: copy/create an `app_*` package, wire it into the workspace, register it, and delete unused platform dirs and any nested `.gitignore`.
- The developer uses Obsidian extensively with Git. Consider compatibility with markdown-based data export where it makes sense (RSS reader saved articles, notes, etc.).
- The developer is security-conscious (uses Aegis, Bitwarden, Mullvad VPN, Tor, Proton services, WireGuard). Code should reflect this: encrypt sensitive local data, minimize permissions, no unnecessary network calls.
