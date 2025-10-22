import Testing
@testable import Beat_Sequencer

/// Tests for the BeatPattern struct
struct BeatPatternTests {

    /// Tests that a new pattern initializes with correct dimensions
    @Test func testInitialization() {
        // Create a default pattern
        let pattern = BeatPattern()

        // Verify dimensions
        #expect(pattern.beatCount == 16)
        #expect(pattern.instrumentCount == 4)
    }

    /// Tests that all beats start as disabled
    @Test func testInitialStateDisabled() {
        let pattern = BeatPattern()

        // Check all positions for all instruments are disabled
        for instrument in Instrument.allCases {
            for position in 0..<pattern.beatCount {
                #expect(pattern.isEnabled(instrument: instrument, at: position) == false)
            }
        }
    }

    /// Tests custom beat count and instrument count initialization
    @Test func testCustomDimensions() {
        // Create a pattern with custom dimensions
        let pattern = BeatPattern(beatCount: 8, instrumentCount: 2)

        // Verify custom dimensions
        #expect(pattern.beatCount == 8)
        #expect(pattern.instrumentCount == 2)
    }

    /// Tests toggling a single beat
    @Test func testToggleBeat() {
        var pattern = BeatPattern()

        // Initially disabled
        #expect(pattern.isEnabled(instrument: .kick, at: 0) == false)

        // Toggle on
        pattern.toggle(instrument: .kick, at: 0)
        #expect(pattern.isEnabled(instrument: .kick, at: 0) == true)

        // Toggle off
        pattern.toggle(instrument: .kick, at: 0)
        #expect(pattern.isEnabled(instrument: .kick, at: 0) == false)
    }

    /// Tests toggling multiple beats
    @Test func testToggleMultipleBeats() {
        var pattern = BeatPattern()

        // Enable several beats
        pattern.toggle(instrument: .kick, at: 0)
        pattern.toggle(instrument: .kick, at: 4)
        pattern.toggle(instrument: .kick, at: 8)
        pattern.toggle(instrument: .kick, at: 12)

        // Verify they're all enabled
        #expect(pattern.isEnabled(instrument: .kick, at: 0) == true)
        #expect(pattern.isEnabled(instrument: .kick, at: 4) == true)
        #expect(pattern.isEnabled(instrument: .kick, at: 8) == true)
        #expect(pattern.isEnabled(instrument: .kick, at: 12) == true)

        // Verify other positions remain disabled
        #expect(pattern.isEnabled(instrument: .kick, at: 1) == false)
        #expect(pattern.isEnabled(instrument: .kick, at: 5) == false)
    }

    /// Tests toggling beats for different instruments
    @Test func testToggleDifferentInstruments() {
        var pattern = BeatPattern()

        // Enable different instruments at same position
        pattern.toggle(instrument: .kick, at: 0)
        pattern.toggle(instrument: .snare, at: 0)
        pattern.toggle(instrument: .hihat, at: 0)

        // Verify all are enabled
        #expect(pattern.isEnabled(instrument: .kick, at: 0) == true)
        #expect(pattern.isEnabled(instrument: .snare, at: 0) == true)
        #expect(pattern.isEnabled(instrument: .hihat, at: 0) == true)

        // Verify clap is still disabled
        #expect(pattern.isEnabled(instrument: .clap, at: 0) == false)
    }

    /// Tests querying enabled instruments at a position
    @Test func testEnabledInstruments() {
        var pattern = BeatPattern()

        // Enable multiple instruments at position 0
        pattern.toggle(instrument: .kick, at: 0)
        pattern.toggle(instrument: .snare, at: 0)

        // Query enabled instruments
        let enabled = pattern.enabledInstruments(at: 0)

        // Verify correct instruments are returned
        #expect(enabled.count == 2)
        #expect(enabled.contains(.kick))
        #expect(enabled.contains(.snare))
        #expect(!enabled.contains(.clap))
        #expect(!enabled.contains(.hihat))
    }

    /// Tests querying enabled instruments at empty position
    @Test func testEnabledInstrumentsEmpty() {
        let pattern = BeatPattern()

        // Query enabled instruments at position with no beats
        let enabled = pattern.enabledInstruments(at: 0)

        // Should return empty array
        #expect(enabled.isEmpty)
    }

    /// Tests boundary conditions for beat positions
    @Test func testBoundaryConditions() {
        var pattern = BeatPattern()

        // Test negative position (should be ignored)
        pattern.toggle(instrument: .kick, at: -1)
        #expect(pattern.isEnabled(instrument: .kick, at: -1) == false)

        // Test position beyond range (should be ignored)
        pattern.toggle(instrument: .kick, at: 100)
        #expect(pattern.isEnabled(instrument: .kick, at: 100) == false)

        // Test valid boundary positions
        pattern.toggle(instrument: .kick, at: 0)
        pattern.toggle(instrument: .kick, at: 15)
        #expect(pattern.isEnabled(instrument: .kick, at: 0) == true)
        #expect(pattern.isEnabled(instrument: .kick, at: 15) == true)
    }

    /// Tests that toggling one beat doesn't affect others
    @Test func testIsolation() {
        var pattern = BeatPattern()

        // Enable one beat
        pattern.toggle(instrument: .kick, at: 5)

        // Verify only that specific beat is affected
        for instrument in Instrument.allCases {
            for position in 0..<pattern.beatCount {
                if instrument == .kick && position == 5 {
                    #expect(pattern.isEnabled(instrument: instrument, at: position) == true)
                } else {
                    #expect(pattern.isEnabled(instrument: instrument, at: position) == false)
                }
            }
        }
    }
}
