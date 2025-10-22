# Beat Sequencer

A simple, performant beat sequencing iOS app built with Swift and SwiftUI.

## TODO

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
