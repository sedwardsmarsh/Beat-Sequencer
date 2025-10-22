import Foundation

/// Stores the enabled/disabled state for each beat position per instrument
struct BeatPattern {
    /// 2D array where:
    ///     rows = instruments
    ///     columns = beat positions
    ///
    /// pattern[instrument][beatPosition] = enabled/disabled
    private(set) var pattern: [[Bool]]

    /// Number of beat positions in the sequence (default: 8)
    let beatCount: Int

    /// Number of instruments (default: 4)
    let instrumentCount: Int

    /// Initializes a new beat pattern with all beats disabled
    /// - Parameters:
    ///   - beatCount: Number of beat positions (default: 8 for 2 bars of 4/4 time)
    ///   - instrumentCount: Number of instruments (default: 4)
    init(beatCount: Int = 8, instrumentCount: Int = 4) {
        self.beatCount = beatCount
        self.instrumentCount = instrumentCount
        // Initialize all beats as disabled (false)
        self.pattern = Array(repeating: Array(repeating: false, count: beatCount), count: instrumentCount)
    }

    /// Returns whether a specific beat is enabled for an instrument
    /// - Parameters:
    ///   - instrument: The instrument to check
    ///   - beatPosition: The beat position to check (0-based)
    /// - Returns: True if the beat is enabled, false otherwise
    func isEnabled(instrument: Instrument, at beatPosition: Int) -> Bool {
        guard beatPosition >= 0 && beatPosition < beatCount else { return false }
        return pattern[instrument.rawValue][beatPosition]
    }

    /// Returns a new pattern with the specified beat toggled
    /// - Parameters:
    ///   - instrument: The instrument to toggle
    ///   - beatPosition: The beat position to toggle (0-based)
    /// - Returns: A new BeatPattern with the beat toggled
    mutating func toggle(instrument: Instrument, at beatPosition: Int) {
        guard beatPosition >= 0 && beatPosition < beatCount else { return }
        pattern[instrument.rawValue][beatPosition].toggle()
    }

    /// Returns all enabled instruments at a specific beat position
    /// - Parameter beatPosition: The beat position to query (0-based)
    /// - Returns: Array of instruments that are enabled at this position
    func enabledInstruments(at beatPosition: Int) -> [Instrument] {
        guard beatPosition >= 0 && beatPosition < beatCount else { return [] }
        return Instrument.allCases.filter { instrument in
            pattern[instrument.rawValue][beatPosition]
        }
    }
}
