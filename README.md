# Beat Sequencer

A simple, performant beat sequencing iOS app built with Swift and SwiftUI.

## TODO

## LOG

10-22-25 11:53 PDT
- (🤖 claude-code) Created ARCH.md with simple architecture design focused on performance and simplicity. The architecture defines 5 layers: Data (BeatPattern, SequencerState), Audio (AudioPlayer with AVAudioEngine), Timer (SequencerTimer), Business Logic (SequencerEngine), and UI (SwiftUI views). Design prioritizes real-time, non-blocking audio playback with pre-loaded buffers to eliminate latency.
- (🤖 claude-code) Implemented data layer models: Instrument enum (maps to audio files), BeatPattern struct (stores 2D grid of enabled/disabled beats), and SequencerState class (observable state for playback, position, BPM, and pattern).
- (🤖 claude-code) Created comprehensive test suites for all data models: InstrumentTests (verifies enum properties), BeatPatternTests (tests toggling, boundaries, isolation), and SequencerStateTests (validates beat advancement, wrapping, BPM clamping between 40-240).
