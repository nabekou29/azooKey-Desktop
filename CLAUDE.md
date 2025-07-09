# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and Install

```bash
# Build and install azooKey for development (with lint checks)
./install.sh

# Build and install without lint checks
./install.sh --ignore-lint

# Dry run (build only, no install)
./install.sh --dry-run
```

### Testing

```bash
# Run Core module tests
swift test --package-path Core

# Run a specific test
swift test --package-path Core --filter <TestName>

# List all tests in Core module
swift test list --package-path Core
```

### Linting

```bash
# Auto-fix fixable lint errors
swiftlint --fix --format

# Check for lint errors (strict mode)
swiftlint --quiet --strict
```

### Package Distribution

```bash
# Create signed and notarized distribution package
./pkgbuild.sh
```

### Development Utilities

```bash
# List available build schemes
xcodebuild -project azooKeyMac.xcodeproj -list

# Kill azooKey process (useful for reloading during development)
pkill azooKeyMac

# Build using xcodebuild directly
xcodebuild -project azooKeyMac.xcodeproj -scheme azooKeyMac clean build
```

## Architecture Overview

azooKey-Desktop is a macOS Japanese input method that uses the neural kana-kanji conversion engine "Zenzai". The codebase is structured as follows:

### Core Components

1. **Core Module** (`/Core`): Platform-independent input logic
   - `InputState`: State machine managing 6 input states (none, deadKeyComposition, composing, previewing, selecting, replaceSuggestion)
   - `UserAction`: User input actions
   - `ClientAction`: Instructions to the IME client
   - Input flow: UserInput → UserAction → InputState.event() → (ClientAction, Callback) → IME Client

2. **azooKeyMac App** (`/azooKeyMac`): macOS-specific implementation using Input Method Kit (IMK)
   - `InputController`: Main IMKInputController subclass handling keyboard events
   - `CandidateWindow`: Candidate display window system
   - `SegmentsManager`: Text segment management for conversion
   - `ConfigWindow`: User configuration interface
   - `OpenAIClient`: LLM-based "good conversion" feature

3. **Zenzai Integration**: Neural conversion engine
   - Dependency: `AzooKeyKanaKanjiConverter` package with Zenzai trait
   - Models stored as submodules: `base_n5_lm`, `zenz-v3-small-gguf`
   - GGUF format model files (~70MB) require Git LFS

### Key Features Implementation

- **Live Conversion**: Real-time conversion suggestions as user types
- **Segment Editing**: Shift+Arrow keys adjust segment boundaries
- **Function Key Conversion**: F6 (hiragana), F7 (katakana), F8 (half-width katakana)
- **Dead Key Composition**: Support for accented characters
- **Profile Prompts**: User-specific conversion learning
- **LLM Conversion**: Context-aware conversion using OpenAI API

### Development Notes

- The project uses SwiftLint with custom rules defined in `.swiftlint.yml`
- Submodules must be properly initialized: `git submodule update --init`
- Git LFS is required for model files
- After building with `install.sh`, the input method needs to be added in System Preferences
- Development builds can be reloaded by killing the azooKeyMac process