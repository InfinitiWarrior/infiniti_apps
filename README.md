# Infiniti Apps

A monorepo of local-first, privacy-focused Android apps, managed with Melos. See `CLAUDE.md` for full project conventions and app-by-app details.

## Structure

```
packages/
├── core/             shared theme, storage, widgets, utils
└── app_calculator/   scientific calculator (first app)
```

## Setup

```bash
dart pub global activate melos   # once
melos bootstrap
```

## Run an app

```bash
cd packages/app_calculator
flutter run -d linux   # fast iteration
flutter run             # connected Android device
```

## Common tasks

```bash
melos run analyze
melos run test
melos run format
```
