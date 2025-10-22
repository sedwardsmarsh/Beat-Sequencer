import Foundation
import Combine

/// Observable state for the beat sequencer
/// Manages playback state, current position, BPM, and beat pattern
class SequencerState: ObservableObject {
    /// Whether the sequencer is currently playing
    @Published var isPlaying: Bool = false

    /// Current beat position in the sequence (0-based)
    @Published var currentBeatPosition: Int = 0

    /// Beats per minute (tempo)
    @Published var bpm: Double = 120.0

    /// The beat pattern defining which instruments play at which positions
    @Published var beatPattern: BeatPattern

    /// Initializes a new sequencer state
    /// - Parameters:
    ///   - beatCount: Number of beats in the pattern (default: 16)
    ///   - initialBPM: Starting tempo (default: 120.0)
    init(beatCount: Int = 16, initialBPM: Double = 120.0) {
        self.beatPattern = BeatPattern(beatCount: beatCount)
        self.bpm = initialBPM
    }

    /// Advances to the next beat position, wrapping to start when reaching the end
    func advanceBeat() {
        currentBeatPosition = (currentBeatPosition + 1) % beatPattern.beatCount
    }

    /// Resets the beat position to the start
    func resetPosition() {
        currentBeatPosition = 0
    }

    /// Toggles a beat in the pattern
    /// - Parameters:
    ///   - instrument: The instrument to toggle
    ///   - beatPosition: The beat position to toggle
    func toggleBeat(instrument: Instrument, at beatPosition: Int) {
        beatPattern.toggle(instrument: instrument, at: beatPosition)
    }

    /// Updates the BPM (tempo)
    /// - Parameter newBPM: The new beats per minute value
    func updateBPM(_ newBPM: Double) {
        // Clamp BPM to reasonable range (40-240)
        self.bpm = max(40.0, min(240.0, newBPM))
    }
}
