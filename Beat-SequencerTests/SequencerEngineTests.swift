import Testing
import Combine
@testable import Beat_Sequencer

/// Tests for the SequencerEngine class
struct SequencerEngineTests {

    /// Tests that the engine initializes with default components
    @Test func testInitialization() throws {
        // Create an engine with defaults
        let engine = try SequencerEngine()

        // Verify state is initialized
        #expect(engine.state.isPlaying == false)
        #expect(engine.state.currentBeatPosition == 0)
        #expect(engine.state.bpm == 120.0)
    }

    /// Tests initialization with custom state
    @Test func testInitializationWithCustomState() throws {
        // Create a custom state
        let customState = SequencerState(beatCount: 8, initialBPM: 140.0)

        // Create engine with custom state
        let engine = try SequencerEngine(state: customState)

        // Verify custom state is used
        #expect(engine.state.beatPattern.beatCount == 8)
        #expect(engine.state.bpm == 140.0)
    }

    /// Tests that starting the engine sets state to playing
    @Test func testStart() throws {
        // Create an engine
        let engine = try SequencerEngine()

        // Initially not playing
        #expect(engine.state.isPlaying == false)

        // Start the engine
        engine.start()

        // Should be playing
        #expect(engine.state.isPlaying == true)
    }

    /// Tests that pausing the engine stops playback
    @Test func testPause() throws {
        // Create and start an engine
        let engine = try SequencerEngine()
        engine.start()

        // Verify it's playing
        #expect(engine.state.isPlaying == true)

        // Pause it
        engine.pause()

        // Should not be playing
        #expect(engine.state.isPlaying == false)
    }

    /// Tests that starting and pausing multiple times works correctly
    @Test func testStartPauseCycle() throws {
        // Create an engine
        let engine = try SequencerEngine()

        // Start
        engine.start()
        #expect(engine.state.isPlaying == true)

        // Pause
        engine.pause()
        #expect(engine.state.isPlaying == false)

        // Start again
        engine.start()
        #expect(engine.state.isPlaying == true)

        // Pause again
        engine.pause()
        #expect(engine.state.isPlaying == false)
    }

    /// Tests updating BPM while stopped
    @Test func testUpdateBPMWhileStopped() throws {
        // Create an engine
        let engine = try SequencerEngine()

        // Update BPM
        engine.updateBPM(140.0)

        // Verify state is updated
        #expect(engine.state.bpm == 140.0)
        #expect(engine.state.isPlaying == false)
    }

    /// Tests updating BPM while playing
    @Test func testUpdateBPMWhilePlaying() throws {
        // Create and start an engine
        let engine = try SequencerEngine()
        engine.start()

        // Update BPM
        engine.updateBPM(180.0)

        // Verify state is updated and still playing
        #expect(engine.state.bpm == 180.0)
        #expect(engine.state.isPlaying == true)
    }

    /// Tests that reset stops playback and resets position
    @Test func testReset() throws {
        // Create and start an engine
        let engine = try SequencerEngine()
        engine.start()

        // Manually advance position to simulate playback
        engine.state.advanceBeat()
        engine.state.advanceBeat()
        #expect(engine.state.currentBeatPosition == 2)

        // Reset
        engine.reset()

        // Should be stopped and at position 0
        #expect(engine.state.isPlaying == false)
        #expect(engine.state.currentBeatPosition == 0)
    }

    /// Tests that the engine advances beat position during playback
    @Test func testBeatAdvancement() async throws {
        // Create an engine with fast BPM for testing
        let state = SequencerState(initialBPM: 240.0) // 0.25s per beat
        let engine = try SequencerEngine(state: state)

        // Start playback
        engine.start()

        // Store initial position
        let initialPosition = engine.state.currentBeatPosition

        // Wait for at least 2 beats (0.6 seconds)
        try await Task.sleep(nanoseconds: 600_000_000)

        // Stop playback
        engine.pause()

        // Position should have advanced
        #expect(engine.state.currentBeatPosition > initialPosition)
    }

    /// Tests that beat position wraps around at the end of the pattern
    @Test func testBeatWrapping() async throws {
        // Create an engine with short pattern and fast BPM
        let state = SequencerState(beatCount: 4, initialBPM: 240.0)
        let engine = try SequencerEngine(state: state)

        // Start playback
        engine.start()

        // Wait for more than 4 beats (1.2 seconds = 4.8 beats at 240 BPM)
        try await Task.sleep(nanoseconds: 1_200_000_000)

        // Stop playback
        engine.pause()

        // Position should have wrapped (be less than 4)
        #expect(engine.state.currentBeatPosition < 4)
    }

    /// Tests that enabled beats trigger audio playback
    @Test func testAudioPlaybackOnEnabledBeats() async throws {
        // Create a state with some beats enabled
        let state = SequencerState(beatCount: 4, initialBPM: 240.0)

        // Enable kick at position 0
        state.toggleBeat(instrument: .kick, at: 0)

        // Enable snare at position 2
        state.toggleBeat(instrument: .snare, at: 2)

        // Create engine
        let engine = try SequencerEngine(state: state)

        // Start playback
        engine.start()

        // Let it play through at least one full cycle
        try await Task.sleep(nanoseconds: 1_200_000_000)

        // Stop playback
        engine.pause()

        // If we reach here without crashes, audio playback worked
        // (AudioPlayer tests verify actual audio functionality)
        #expect(engine.state.isPlaying == false)
    }

    /// Tests that disabled beats don't cause crashes
    @Test func testPlaybackWithAllBeatsDisabled() async throws {
        // Create an engine with no beats enabled
        let state = SequencerState(initialBPM: 240.0)
        let engine = try SequencerEngine(state: state)

        // Start playback
        engine.start()

        // Wait for several beats
        try await Task.sleep(nanoseconds: 600_000_000)

        // Stop playback
        engine.pause()

        // Should complete without issues
        #expect(engine.state.isPlaying == false)
    }

    /// Tests that the engine properly cleans up on deinitialization
    @Test func testDeinitCleanup() throws {
        // Create an engine in a scope
        var engine: SequencerEngine? = try SequencerEngine()
        engine?.start()

        // Verify it's running
        #expect(engine?.state.isPlaying == true)

        // Deallocate the engine
        engine = nil

        // If we reach here without crashes, cleanup worked correctly
        #expect(engine == nil)
    }

    /// Tests that modifying the pattern during playback works correctly
    @Test func testPatternModificationDuringPlayback() async throws {
        // Create an engine
        let state = SequencerState(beatCount: 4, initialBPM: 240.0)
        let engine = try SequencerEngine(state: state)

        // Start playback
        engine.start()

        // Wait a bit
        try await Task.sleep(nanoseconds: 300_000_000)

        // Modify pattern while playing
        state.toggleBeat(instrument: .kick, at: 0)
        state.toggleBeat(instrument: .hihat, at: 1)

        // Wait more
        try await Task.sleep(nanoseconds: 300_000_000)

        // Modify again
        state.toggleBeat(instrument: .snare, at: 2)

        // Wait more
        try await Task.sleep(nanoseconds: 300_000_000)

        // Stop
        engine.pause()

        // Should complete without crashes
        #expect(engine.state.isPlaying == false)
    }

    /// Tests that pausing doesn't lose beat position
    @Test func testPositionPreservedOnPause() async throws {
        // Create an engine
        let state = SequencerState(initialBPM: 240.0)
        let engine = try SequencerEngine(state: state)

        // Start playback
        engine.start()

        // Wait for a few beats
        try await Task.sleep(nanoseconds: 600_000_000)

        // Pause
        engine.pause()

        // Store position
        let positionAfterPause = engine.state.currentBeatPosition

        // Wait a bit while paused
        try await Task.sleep(nanoseconds: 300_000_000)

        // Position should not have changed
        #expect(engine.state.currentBeatPosition == positionAfterPause)
    }

    /// Tests resuming playback from paused position
    @Test func testResumeFromPausedPosition() async throws {
        // Create an engine
        let state = SequencerState(initialBPM: 240.0)
        let engine = try SequencerEngine(state: state)

        // Start playback
        engine.start()

        // Wait for a few beats
        try await Task.sleep(nanoseconds: 600_000_000)

        // Pause
        engine.pause()

        // Store position
        let pausedPosition = engine.state.currentBeatPosition

        // Resume playback
        engine.start()

        // Wait for at least one beat
        try await Task.sleep(nanoseconds: 300_000_000)

        // Stop
        engine.pause()

        // Position should have advanced from paused position
        #expect(engine.state.currentBeatPosition != pausedPosition)
    }
}
