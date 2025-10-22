import Testing
@testable import Beat_Sequencer

/// Tests for the SequencerState class
struct SequencerStateTests {

    /// Tests that state initializes with correct default values
    @Test func testInitialization() {
        let state = SequencerState()

        // Verify default values
        #expect(state.isPlaying == false)
        #expect(state.currentBeatPosition == 0)
        #expect(state.bpm == 120.0)
        #expect(state.beatPattern.beatCount == 16)
    }

    /// Tests initialization with custom values
    @Test func testCustomInitialization() {
        let state = SequencerState(beatCount: 8, initialBPM: 140.0)

        // Verify custom values
        #expect(state.beatPattern.beatCount == 8)
        #expect(state.bpm == 140.0)
    }

    /// Tests advancing beat position
    @Test func testAdvanceBeat() {
        let state = SequencerState()

        // Start at position 0
        #expect(state.currentBeatPosition == 0)

        // Advance to position 1
        state.advanceBeat()
        #expect(state.currentBeatPosition == 1)

        // Advance to position 2
        state.advanceBeat()
        #expect(state.currentBeatPosition == 2)
    }

    /// Tests that advancing wraps around at the end
    @Test func testAdvanceBeatWrapping() {
        let state = SequencerState()

        // Advance to the last position (15 for 16-beat pattern)
        for _ in 0..<15 {
            state.advanceBeat()
        }
        #expect(state.currentBeatPosition == 15)

        // Advance once more should wrap to 0
        state.advanceBeat()
        #expect(state.currentBeatPosition == 0)
    }

    /// Tests resetting position
    @Test func testResetPosition() {
        let state = SequencerState()

        // Advance to middle of sequence
        for _ in 0..<8 {
            state.advanceBeat()
        }
        #expect(state.currentBeatPosition == 8)

        // Reset should return to 0
        state.resetPosition()
        #expect(state.currentBeatPosition == 0)
    }

    /// Tests toggling beats through state
    @Test func testToggleBeat() {
        let state = SequencerState()

        // Initially no beats enabled
        #expect(state.beatPattern.isEnabled(instrument: .kick, at: 0) == false)

        // Toggle through state
        state.toggleBeat(instrument: .kick, at: 0)
        #expect(state.beatPattern.isEnabled(instrument: .kick, at: 0) == true)

        // Toggle off
        state.toggleBeat(instrument: .kick, at: 0)
        #expect(state.beatPattern.isEnabled(instrument: .kick, at: 0) == false)
    }

    /// Tests updating BPM
    @Test func testUpdateBPM() {
        let state = SequencerState()

        // Initial BPM is 120
        #expect(state.bpm == 120.0)

        // Update to new value
        state.updateBPM(140.0)
        #expect(state.bpm == 140.0)

        // Update to different value
        state.updateBPM(90.0)
        #expect(state.bpm == 90.0)
    }

    /// Tests BPM clamping to minimum
    @Test func testBPMClampingMinimum() {
        let state = SequencerState()

        // Try to set below minimum (40)
        state.updateBPM(20.0)
        #expect(state.bpm == 40.0)

        // Try to set to 0
        state.updateBPM(0.0)
        #expect(state.bpm == 40.0)

        // Try negative value
        state.updateBPM(-50.0)
        #expect(state.bpm == 40.0)
    }

    /// Tests BPM clamping to maximum
    @Test func testBPMClampingMaximum() {
        let state = SequencerState()

        // Try to set above maximum (240)
        state.updateBPM(300.0)
        #expect(state.bpm == 240.0)

        // Try very large value
        state.updateBPM(1000.0)
        #expect(state.bpm == 240.0)
    }

    /// Tests BPM accepts valid range
    @Test func testBPMValidRange() {
        let state = SequencerState()

        // Test minimum valid value
        state.updateBPM(40.0)
        #expect(state.bpm == 40.0)

        // Test maximum valid value
        state.updateBPM(240.0)
        #expect(state.bpm == 240.0)

        // Test middle values
        state.updateBPM(120.0)
        #expect(state.bpm == 120.0)

        state.updateBPM(180.0)
        #expect(state.bpm == 180.0)
    }

    /// Tests that playing state can be toggled
    @Test func testPlayingState() {
        let state = SequencerState()

        // Initially not playing
        #expect(state.isPlaying == false)

        // Manually set to playing (engine will do this)
        state.isPlaying = true
        #expect(state.isPlaying == true)

        // Set back to not playing
        state.isPlaying = false
        #expect(state.isPlaying == false)
    }
}
