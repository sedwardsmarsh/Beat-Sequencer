import Testing
@testable import Beat_Sequencer

/// Tests for the Instrument enum
struct InstrumentTests {

    /// Tests that all four instrument cases exist
    @Test func testAllCases() {
        // Verify we have exactly 4 instruments
        #expect(Instrument.allCases.count == 4)

        // Verify each instrument exists
        let instruments = Instrument.allCases
        #expect(instruments.contains(.kick))
        #expect(instruments.contains(.clap))
        #expect(instruments.contains(.snare))
        #expect(instruments.contains(.hihat))
    }

    /// Tests that each instrument has the correct display name
    @Test func testDisplayNames() {
        #expect(Instrument.kick.displayName == "kick")
        #expect(Instrument.clap.displayName == "clap")
        #expect(Instrument.snare.displayName == "snare")
        #expect(Instrument.hihat.displayName == "hihat")
    }

    /// Tests that each instrument has the correct audio file name
    @Test func testAudioFileNames() {
        #expect(Instrument.kick.audioFileName == "(Lay Down) Blackout Kick.wav")
        #expect(Instrument.clap.audioFileName == "dry-clap-12.wav")
        #expect(Instrument.snare.audioFileName == "(Lay Down) Snare.wav")
        #expect(Instrument.hihat.audioFileName == "(About You) Hat Closed.wav")
    }

    /// Tests that each instrument has the correct audio folder name
    @Test func testAudioFolderNames() {
        #expect(Instrument.kick.audioFolderName == "kick")
        #expect(Instrument.clap.audioFolderName == "clap")
        #expect(Instrument.snare.audioFolderName == "snare")
        #expect(Instrument.hihat.audioFolderName == "hihat")
    }

    /// Tests that raw values are correct and sequential
    @Test func testRawValues() {
        #expect(Instrument.kick.rawValue == 0)
        #expect(Instrument.clap.rawValue == 1)
        #expect(Instrument.snare.rawValue == 2)
        #expect(Instrument.hihat.rawValue == 3)
    }
}
