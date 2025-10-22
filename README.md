# Beat Sequencer

A simple, ~~performant~~ beat sequencing iOS app built with Swift and SwiftUI.

## TODO

- BPM sequencer fails at higher BPMs (>= 200)
- Audio playback continues after stopping sequencer for higher BPMs (>= 200)
- Improve accessibility via dark mode to prevent blinding user
- Add random sequence button to create a "random-not-random" sequence from a pre loaded library of sequences
- Add drop-down menus per instrument category to allow user to change sounds for each instrument
- Add recording capabilities to allow user to add their own sounds

## LOG

10-22-25 11:53 PDT
- (🤖 claude-code) Created ARCH.md with simple architecture design focused on performance and simplicity. The architecture defines 5 layers: Data (BeatPattern, SequencerState), Audio (AudioPlayer with AVAudioEngine), Timer (SequencerTimer), Business Logic (SequencerEngine), and UI (SwiftUI views). Design prioritizes real-time, non-blocking audio playback with pre-loaded buffers to eliminate latency.
- (🤖 claude-code) Implemented data layer models: Instrument enum (maps to audio files), BeatPattern struct (stores 2D grid of enabled/disabled beats), and SequencerState class (observable state for playback, position, BPM, and pattern).
- (🤖 claude-code) Created comprehensive test suites for all data models: InstrumentTests (verifies enum properties), BeatPatternTests (tests toggling, boundaries, isolation), and SequencerStateTests (validates beat advancement, wrapping, BPM clamping between 40-240).

10-22-25 12:17 PDT
- (🤖 claude-code) Implemented AudioPlayer class using AVAudioEngine with pre-loaded PCM buffers for zero-latency playback. The player pre-loads all four instrument audio files during initialization and provides a non-blocking play method that schedules buffers immediately without waiting for completion.
- (🤖 claude-code) Created AudioPlayerTests with 7 integration tests covering initialization, simultaneous playback of multiple instruments, rapid sequential playback stress testing, and engine lifecycle management (stop/start).

10-22-25 13:04 PDT
- (🤖 claude-code) Simplified audio file loading by moving audio files to bundle root and renaming to match instrument categories (kick.wav, clap.wav, snare.wav, hihat.wav). Removed bundle parameter from AudioPlayer initialization and eliminated subdirectory path logic. Updated Instrument enum to return simplified filenames and removed audioFolderName property.

10-22-25 13:09 PDT
- (🤖 claude-code) Implemented SequencerTimer class using Combine's Timer.publish() for precise beat timing. The timer calculates intervals from BPM (60.0 / BPM), publishes beat events on the main thread, and supports dynamic BPM updates with automatic restart. Includes start/stop methods and automatic cleanup on deinitialization.
- (🤖 claude-code) Created SequencerTimerTests with 13 tests covering initialization, start/stop lifecycle, BPM updates (while running and stopped), interval calculations, beat event publishing with timing verification, and cleanup on deinitialization.

10-22-25 13:19 PDT
- (🤖 claude-code) Implemented SequencerEngine class coordinating AudioPlayer, SequencerTimer, and SequencerState. The engine subscribes to timer beat events, queries the pattern for enabled instruments, triggers non-blocking audio playback, and advances beat position with automatic wrapping. Includes start/pause/reset methods and BPM update support.
- (🤖 claude-code) Created SequencerEngineTests with 15 tests covering initialization, start/pause/reset lifecycle, BPM updates, beat advancement with wrapping, audio playback integration, pattern modification during playback, pause/resume behavior, and cleanup on deinitialization.

10-22-25 13:28 PDT
- (🤖 claude-code) Implemented complete UI layer with three SwiftUI views. ControlPanelView provides play/pause buttons with state-based styling and BPM text field with validation. SequencerGridView displays 4x16 grid of beat buttons with toggle functionality, current position highlighting, and instrument labels. ContentView owns SequencerEngine as StateObject and composes child views with proper state binding.
- (🤖 claude-code) Added SwiftUI previews for all three views. ControlPanelView preview creates sample engine and state. SequencerGridView preview includes preset beat pattern (kick on downbeats, snare on backbeats, hihat on offbeats) with current position highlighting at beat 4. ContentView preview uses default initialization.

10-22-25 13:43 PDT
- (🤖 claude-code) Refined UI layout for better usability. Reduced sequencer grid from 16 to 8 beats to fit screen width. Combined play/pause into single toggle button with dynamic icon and color (blue for play, red for pause). Reorganized BPM controls into vertical stack with label above textfield and set button below for clearer hierarchy.
- (🤖 claude-code) Updated default beat count from 16 to 8 in BeatPattern and SequencerState. Modified ARCH.md to reflect 8 beats (2 bars of 4/4 time). Updated SequencerGridView preview with 8-beat pattern.
