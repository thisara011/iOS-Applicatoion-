# IOS Demo App

A multi-mode iOS game hub built with **SwiftUI**, **SwiftData**, and lightweight service-based architecture. The app currently includes three experiences: **Tap Frenzy**, **Light It Up**, and **Quiz Rush**.

---

## Features

### Game Hub
- Central home screen for navigating between games
- Live high-score display for each supported mode
- Modern card-based layout with native iOS styling

### Tap Frenzy
- Fast tap challenge with a 20-second round
- Persistent high score using `@AppStorage`
- Back navigation for returning to the hub
- Simple, responsive gameplay loop

### Light It Up
- 60-second arcade mode
- Progressive difficulty across multiple levels
- Dynamic card grid and visual feedback
- Audio feedback and animated interactions
- Persistent high score using `@AppStorage`

### Quiz Rush
- Live trivia gameplay powered by Open Trivia DB
- 10-question rounds with score tracking
- Correct/wrong feedback and restart flow
- Preview-safe mock data support
- Persistent high score using `@AppStorage`

### Shared App Infrastructure
- SwiftData-backed session storage
- Shared result and score UI components
- Navigation-based screen flow
- Asset and sound-file integration

---

## Architecture Overview

The project uses a feature-oriented SwiftUI structure.

```text
IOS Demo App
├── IOS_Demo_AppApp.swift        # Main app entry point
├── Views/
│   └── HomeScreenView.swift     # Game hub / launcher
├── Games/
│   ├── TapFrenzyView.swift
│   ├── LightItUpGameView.swift
│   ├── QuizRushView.swift
│   └── LegacyTapFrenzyView.swift
├── ViewModels/
│   └── QuizRushViewModel.swift
├── Models/
│   ├── Card.swift
│   ├── GameMode.swift
│   ├── GameSession.swift
│   ├── Item.swift
│   └── QuizRushModels.swift
├── Services/
│   ├── SessionStore.swift
│   └── TriviaAPI.swift
├── Shared/
│   ├── ResultView.swift
│   └── ScoreBadge.swift
└── Tabs/
    ├── MainTabView.swift
    ├── HomeTab.swift
    ├── MapTab.swift
    ├── SettingsTab.swift
    ├── StatsTab.swift
    └── TabsNamespace.swift
```

### Design principles
- **SwiftUI-first** view composition
- **Feature separation** by folder and screen responsibility
- **State management** with `@State`, `@StateObject`, `@AppStorage`, and `@EnvironmentObject`
- **Persistence** through SwiftData and `UserDefaults`
- **Service abstraction** for remote trivia loading

### Data flow
1. The app launches into `HomeScreenView`.
2. Users choose a game mode.
3. Gameplay state stays local to each screen or view model.
4. High scores are stored with `@AppStorage`.
5. Session history is handled by `SessionStore` and `GameSession` where applicable.

---

## Known Limitations

- **Trivia requires network access**: `Quiz Rush` fetches live questions from Open Trivia DB, so it can fail or show an error state when offline.
- **Preview behavior depends on Xcode caching**: SwiftUI Canvas may need a clean build or DerivedData reset if stale preview metadata appears.
- **Legacy files remain in the repo**: Some older or compatibility-oriented files still exist and can be confusing at first glance.
- **No formal test suite yet**: The project does not currently include extensive automated gameplay or UI tests.
- **Asset pipeline is manual**: Sounds and images are bundled directly; there is no advanced import workflow or asset manager.
- **Quiz data is not cached offline**: Trivia questions are fetched live each round.

---

## Reflection

This app evolved from a very small demo into a more complete multi-game experience. The biggest improvement was not just adding more content, but organizing the code so each screen has a clear job.

### What worked well
- Splitting each game into its own view kept the code easier to understand.
- Using `@AppStorage` made high-score persistence simple and reliable.
- Extracting trivia logic into a service improved structure and preview support.
- Keeping shared UI pieces in dedicated files reduced repetition.

### What could be improved next
- Remove or consolidate legacy files.
- Add more robust offline support for trivia.
- Introduce stronger theming and reusable design tokens.
- Add automated tests for game logic and navigation.
- Add screenshots and badges for a stronger GitHub landing page.

### Takeaway
The app now behaves more like a small feature-driven product than a single demo screen. That makes it easier to extend, preview, debug, and maintain.

---

## Getting Started

### Requirements
- Xcode 17 or later
- iOS 26.5 simulator or compatible device target
- SwiftUI and SwiftData support

### Run locally
1. Open `IOS Demo App.xcodeproj`
2. Select the `IOS Demo App` scheme
3. Run on a simulator or device

### If previews fail
- Clean the build folder in Xcode
- Delete the project’s DerivedData
- Reopen Canvas and resume previews

---

## Project Highlights

- `Views/HomeScreenView.swift` — game hub launcher
- `Games/TapFrenzyView.swift` — tap challenge mode
- `Games/LightItUpGameView.swift` — progressive card-tapping mode
- `Games/QuizRushView.swift` — trivia mode with mock preview data
- `ViewModels/QuizRushViewModel.swift` — quiz state and answer logic
- `Services/TriviaAPI.swift` — Open Trivia DB client
- `Services/SessionStore.swift` — persisted session history
- `Models/GameSession.swift` — session record model

---

## Future Ideas

- Add leaderboards
- Cache trivia questions for offline play
- Add sound toggles in Settings
- Add animated game-over screens per mode
- Replace legacy placeholders with finalized code paths

---

## License

No explicit license is included yet. Add one if you plan to publish or share the project publicly.
