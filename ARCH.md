# Architecture Document

## Overview

This document outlines the simple architecture for the Beat Sequencer iOS app. The design prioritizes simplicity, performance, and real-time audio playback without complexity.

## Core Principles

1. **Simplicity First**: Minimize abstractions and keep component count low
2. **Real-time Performance**: Non-blocking audio playback with precise timing
3. **Single Responsibility**: Each component has one clear purpose
4. **Testability**: All components are independently testable

## Architecture Layers

### 1. Data Layer

**BeatPattern** (Struct)
- Stores enabled/disabled state for each beat position per instrument
- Simple 2D array: `[[Bool]]` where rows = instruments, columns = beats
- Immutable state updates for SwiftUI compatibility

**SequencerState** (Class, ObservableObject)
- Current playback state (playing/paused)
- Current beat position (0-based index)
- BPM (beats per minute)
- Beat pattern reference
- Published properties for SwiftUI binding

### 2. Audio Layer

**AudioPlayer** (Class)
- Loads audio files from `instrument-audio/` folder
- Plays audio samples on demand
- **Critical**: Uses `AVAudioEngine` with pre-loaded buffers for zero-latency playback
- Non-blocking fire-and-forget playback method
- One method: `play(instrument:)` - no waiting, no callbacks

**Instruments** (Enum)
- Four cases: `kick`, `clap`, `snare`, `hihat`
- Maps to audio file names
- Type-safe instrument references

### 3. Timer Layer

**SequencerTimer** (Class)
- Central timing coordinator
- Uses `Timer.publish()` for consistent beat intervals
- Calculates interval from BPM: `interval = 60.0 / BPM`
- Publishes beat events to advance sequencer
- Start/stop methods only

### 4. Business Logic Layer

**SequencerEngine** (Class)
- Coordinates timer, audio, and state
- Subscribes to timer beat events
- On each beat:
  1. Check current beat position in pattern
  2. Trigger audio for enabled instruments (non-blocking)
  3. Advance beat position
  4. Loop back to start when sequence completes
- Methods: `start()`, `pause()`, `updateBPM(_:)`

### 5. UI Layer

**ControlPanelView** (SwiftUI View)
- HStack with three controls:
  - Play button → calls `engine.start()`
  - Pause button → calls `engine.pause()`
  - TextField for BPM → calls `engine.updateBPM(_:)`
- Binds to `SequencerState` for UI updates

**SequencerGridView** (SwiftUI View)
- VStack of rows (one per instrument)
- Each row: HStack of circle buttons (one per beat position)
- Instrument label before each row
- Tapping circle toggles beat in pattern
- Visual indicator shows current playing beat
- Binds to `SequencerState` for pattern and position

**ContentView** (SwiftUI View)
- Main container
- VStack containing:
  1. ControlPanelView
  2. SequencerGridView
- Owns SequencerEngine instance
- Passes state bindings to child views

## Data Flow

```
User Input (UI)
  → SequencerEngine
    → Updates SequencerState
      → SwiftUI auto-updates views

Timer Event
  → SequencerEngine.onBeat()
    → Reads BeatPattern from SequencerState
    → Calls AudioPlayer.play() for enabled instruments (non-blocking)
    → Updates current beat position in SequencerState
      → SwiftUI highlights current beat
```

## File Structure

```
Beat-Sequencer/
├── Models/
│   ├── BeatPattern.swift
│   ├── SequencerState.swift
│   └── Instrument.swift
├── Audio/
│   └── AudioPlayer.swift
├── Engine/
│   ├── SequencerTimer.swift
│   └── SequencerEngine.swift
├── Views/
│   ├── ContentView.swift
│   ├── ControlPanelView.swift
│   └── SequencerGridView.swift
└── Tests/
    ├── BeatPatternTests.swift
    ├── AudioPlayerTests.swift
    ├── SequencerTimerTests.swift
    ├── SequencerEngineTests.swift
    └── (UI tests as needed)
```

## Performance Considerations

### Audio Latency Elimination
- Pre-load all audio files at app launch
- Use `AVAudioPlayerNode` with scheduled buffers
- Never allocate memory during playback
- Fire-and-forget playback (no waiting for completion)

### Timer Precision
- Use Combine's `Timer.publish()` on main thread
- Keep beat handler lightweight (< 1ms execution)
- Avoid any blocking operations in timer callback

### State Updates
- All state changes on main thread
- SwiftUI automatic diffing handles UI updates efficiently
- No manual threading required

## Testing Strategy

### Unit Tests
- BeatPattern: Toggle operations, pattern queries
- AudioPlayer: File loading, playback triggering (mock AVAudioEngine)
- SequencerTimer: Interval calculation, start/stop
- SequencerEngine: Beat advancement, pattern playback logic

### Integration Tests
- Full playback cycle with mock timer
- BPM changes during playback
- Pattern modifications during playback

### UI Tests (Optional)
- Button interactions
- Pattern grid toggling
- Visual state verification

## Constraints & Simplifications

1. **Fixed Grid Size**: 8 beats per pattern (4/4 time, 2 measures)
2. **Fixed Instruments**: Exactly 4 instruments (no dynamic addition)
3. **No Persistence**: Pattern resets on app restart (can add later)
4. **No Undo/Redo**: Direct state manipulation only
5. **No Audio Effects**: Raw sample playback only

## Future Enhancements (Out of Scope)

- Pattern save/load
- Multiple pattern banks
- Adjustable grid size
- Volume controls per instrument
- Audio effects (reverb, delay)
- Tempo tap input
- Visual waveforms
