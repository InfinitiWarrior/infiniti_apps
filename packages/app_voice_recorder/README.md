# app_voice_recorder

Local-only voice recorder. Record, pause/resume, stop, play back, rename, and delete recordings — no cloud, no telemetry. Choose AAC or WAV capture format in Settings.

Part of the [Infiniti Apps](../../README.md) monorepo — see the root `CLAUDE.md` for shared conventions.

## Run

```bash
flutter run -d linux   # UI iteration (no real mic capture on desktop without hardware access)
flutter run             # connected Android device
```
