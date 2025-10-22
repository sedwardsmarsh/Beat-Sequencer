import Testing
import AVFoundation
@testable import Beat_Sequencer

/// Tests for the AudioPlayer class
/// Note: These are integration tests that verify the audio system works with real files
struct AudioPlayerTests {

    /// Tests that the audio player initializes successfully
    @Test func testInitialization() throws {
        // Create an audio player
        let player = try AudioPlayer()

        // Verify the engine is running after initialization
        #expect(player.isEngineRunning == true)
    }

    /// Tests that the audio player can play each instrument without crashing
    @Test func testPlayAllInstruments() throws {
        // Create an audio player
        let player = try AudioPlayer()

        // Play each instrument (this should not throw or crash)
        for instrument in Instrument.allCases {
            player.play(instrument: instrument)
        }

        // If we reach here, all instruments played successfully
        #expect(player.isEngineRunning == true)
    }

    /// Tests that the audio player can play the same instrument multiple times
    @Test func testPlaySameInstrumentMultipleTimes() throws {
        // Create an audio player
        let player = try AudioPlayer()

        // Play the same instrument several times in succession
        for _ in 0..<5 {
            player.play(instrument: .kick)
        }

        // Should not crash and engine should still be running
        #expect(player.isEngineRunning == true)
    }

    /// Tests that the audio player can play multiple instruments simultaneously
    @Test func testPlayMultipleInstrumentsSimultaneously() throws {
        // Create an audio player
        let player = try AudioPlayer()

        // Play all instruments at once (simulating a beat with all instruments)
        player.play(instrument: .kick)
        player.play(instrument: .clap)
        player.play(instrument: .snare)
        player.play(instrument: .hihat)

        // Should not crash and engine should still be running
        #expect(player.isEngineRunning == true)
    }

    /// Tests that stopping the audio player works correctly
    @Test func testStop() throws {
        // Create an audio player
        let player = try AudioPlayer()

        // Verify engine is running
        #expect(player.isEngineRunning == true)

        // Stop the player
        player.stop()

        // Verify engine is no longer running
        #expect(player.isEngineRunning == false)
    }

    /// Tests that the player can be stopped and instruments can still be called
    @Test func testPlayAfterStop() throws {
        // Create an audio player
        let player = try AudioPlayer()

        // Stop the player
        player.stop()

        // Try to play an instrument (should not crash even though engine is stopped)
        player.play(instrument: .kick)

        // Verify engine is still stopped
        #expect(player.isEngineRunning == false)
    }

    /// Tests rapid sequential playback (stress test)
    @Test func testRapidSequentialPlayback() throws {
        // Create an audio player
        let player = try AudioPlayer()

        // Rapidly play instruments in sequence (simulating a fast tempo)
        for _ in 0..<20 {
            for instrument in Instrument.allCases {
                player.play(instrument: instrument)
            }
        }

        // Should handle rapid playback without issues
        #expect(player.isEngineRunning == true)
    }
}
