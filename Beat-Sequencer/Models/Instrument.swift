import Foundation

/// Represents the four instrument types available in the beat sequencer
/// Maps to audio files in the instrument-audio folder
enum Instrument: Int, CaseIterable {
    case kick = 0
    case clap = 1
    case snare = 2
    case hihat = 3

    /// Returns the display name for the instrument
    /// Used in the UI to label each row
    var displayName: String {
        switch self {
        case .kick: return "kick"
        case .clap: return "clap"
        case .snare: return "snare"
        case .hihat: return "hihat"
        }
    }

    /// Returns the audio file name for the instrument
    /// Maps to the actual audio file in the bundle
    var audioFileName: String {
        switch self {
        case .kick: return "kick.wav"
        case .clap: return "clap.wav"
        case .snare: return "snare.wav"
        case .hihat: return "hihat.wav"
        }
    }
}
