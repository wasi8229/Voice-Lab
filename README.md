# Voice Lab — Flutter App

A complete Flutter (Dart) port of the Voice Lab AI-Powered Voice Generation Studio.

## Features

- 🎙️ **Voice Studio** — TTS text-to-speech generation with 100+ AI voices
- ✂️ **Voice Editor** — Audio trim, FX effects, waveform visualization
- 📚 **Voice Catalog** — Browse, search, and filter voices by language/category
- 🎬 **Media Voice Cloning** — Clone voices from audio/video files
- 🔐 **Authentication** — Login/Signup with JWT tokens
- 🔊 **Audio Playback** — Built-in player with progress bar and controls
- 🌐 **Urdu Support** — RTL text rendering for Urdu scripts
- 📱 **Android + iOS** — Native cross-platform app

[//]: # (## Architecturer)
[//]: # ()
[//]: # (```)
[//]: # (flutter_app/)
[//]: # (├── lib/)
[//]: # (│   ├── main.dart                    # App entry point)
[//]: # (│   ├── models/)
[//]: # (│   │   ├── voice_model.dart         # Voice data model)
[//]: # (│   │   ├── user_model.dart          # User data model)
[//]: # (│   │   └── generation_result.dart   # TTS result model)
[//]: # (│   ├── providers/)
[//]: # (│   │   └── app_state.dart           # Global state &#40;ChangeNotifier&#41;)
[//]: # (│   ├── services/)
[//]: # (│   │   └── api_service.dart         # HTTP API calls)
[//]: # (│   ├── theme/)
[//]: # (│   │   └── app_theme.dart           # Colors, text styles, decorations)
[//]: # (│   ├── screens/)
[//]: # (│   │   ├── home_screen.dart         # Main shell &#40;AppBar + BottomNav&#41;)
[//]: # (│   │   ├── voice_studio_screen.dart # TTS generation screen)
[//]: # (│   │   ├── voice_editor_screen.dart # Audio editor screen)
[//]: # (│   │   └── voice_catalog_screen.dart# Voice browser screen)
[//]: # (│   └── widgets/)
[//]: # (│       ├── auth_modal.dart          # Login/Signup modal overlay)
[//]: # (│       ├── media_clone_modal.dart   # Media voice cloning modal)
[//]: # (│       ├── voice_selector_sheet.dart# Bottom sheet voice picker)
[//]: # (│       ├── vocal_fx_panel.dart      # Vocal FX controls widget)
[//]: # (│       └── clone_voice_sheet.dart   # Manual voice clone bottom sheet)
[//]: # (├── android/                         # Android-specific files)
[//]: # (├── pubspec.yaml                     # Flutter dependencies)
[//]: # (└── README.md                        # This file)
[//]: # (```)
[//]: # ()
[//]: # (## Backend Connection)
[//]: # ()
[//]: # (This Flutter app connects to the existing Node.js + FastAPI backend. Update the `baseUrl` in `lib/services/api_service.dart`:)
[//]: # ()
[//]: # (```dart)
[//]: # (// For local development &#40;Android emulator&#41;)
[//]: # (static const String baseUrl = 'http://10.0.2.2:3000';)
[//]: # ()
[//]: # (// For physical device &#40;replace with your machine's IP&#41;)
[//]: # (static const String baseUrl = 'http://192.168.1.x:3000';)
[//]: # ()
[//]: # (// For production deployment)
[//]: # (static const String baseUrl = 'https://your-deployed-domain.com';)
[//]: # (```)
[//]: # ()
[//]: # (## Setup & Run)
[//]: # ()
[//]: # (### Prerequisites)
[//]: # (- Flutter SDK >= 3.0.0 &#40;https://flutter.dev/docs/get-started/install&#41;)
[//]: # (- Android Studio or VS Code with Flutter extension)
[//]: # (- Running backend server &#40;see root README.md&#41;)
[//]: # ()
[//]: # (### Steps)
[//]: # ()
[//]: # (```bash)
[//]: # (# 1. Navigate to flutter_app)
[//]: # (cd flutter_app)
[//]: # ()
[//]: # (# 2. Install dependencies)
[//]: # (flutter pub get)
[//]: # ()
[//]: # (# 3. Run on Android &#40;with emulator/device connected&#41;)
[//]: # (flutter run)
[//]: # ()
[//]: # (# 4. Build APK for release)
[//]: # (flutter build apk --release)
[//]: # (```)
[//]: # ()
[//]: # (## API Endpoints Used)
[//]: # ()
[//]: # (| Endpoint | Method | Purpose |)
[//]: # (|----------|--------|---------|)
[//]: # (| `/api/auth/login` | POST | User login |)
[//]: # (| `/api/auth/signup` | POST | User registration |)
[//]: # (| `/api/auth/me` | GET | Fetch current user |)
[//]: # (| `/api/voices` | GET | List all voices |)
[//]: # (| `/api/voices/clone` | POST | Create voice clone |)
[//]: # (| `/api/voices/:id` | DELETE | Delete custom voice |)
[//]: # (| `/api/tts/generate` | POST | Generate TTS audio |)
[//]: # (| `/api/tts/audio` | GET | Stream audio for preview |)
[//]: # (| `/api/tts/download/:file` | GET | Download WAV/MP3 |)
[//]: # ()
[//]: # (## Design System)
[//]: # ()
[//]: # (The app uses a design system matching the original React web app:)
[//]: # (- **Primary**: `#1264D8` &#40;deep blue&#41;)
[//]: # (- **Accent**: `#00BFA6` &#40;teal green&#41;)
[//]: # (- **Background**: `#F8FAFC` &#40;off-white&#41;)
[//]: # (- **Dark**: `#0F2742` &#40;navy — used in hero cards&#41;)
[//]: # ()
[//]: # (## Packages Used)
[//]: # ()
[//]: # (| Package | Purpose |)
[//]: # (|---------|---------|)
| `provider` | State management |
| `http` | API calls |
| `shared_preferences` | Token persistence |
| `audioplayers` | Audio playback |
| `file_picker` | File upload |
| `record` | Microphone recording |
| `permission_handler` | Runtime permissions |
| `google_fonts` | Typography |
| `intl` | Date/number formatting |
