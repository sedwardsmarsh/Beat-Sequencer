import SwiftUI

/// Grid view for the beat sequencer
/// Displays rows of beat buttons for each instrument
struct SequencerGridView: View {
    /// The sequencer state (observed for UI updates)
    @ObservedObject var state: SequencerState

    var body: some View {
        VStack(spacing: 12) {
            // Iterate through all instruments to create rows
            ForEach(Instrument.allCases, id: \.rawValue) { instrument in
                // Each row contains instrument label and beat buttons
                HStack(spacing: 8) {
                    // Instrument label
                    Text(instrument.displayName)
                        .font(.headline)
                        .frame(width: 60, alignment: .leading)

                    // Beat buttons for this instrument
                    ForEach(0..<state.beatPattern.beatCount, id: \.self) { beatPosition in
                        // Circle button for each beat
                        BeatButton(
                            instrument: instrument,
                            beatPosition: beatPosition,
                            state: state
                        )
                    }
                }
            }
        }
        .padding()
    }
}

/// Individual beat button in the sequencer grid
/// Displays as a circle that can be toggled on/off
struct BeatButton: View {
    /// The instrument this button controls
    let instrument: Instrument

    /// The beat position this button represents
    let beatPosition: Int

    /// The sequencer state (observed for UI updates)
    @ObservedObject var state: SequencerState

    /// Size of the beat button
    private let buttonSize: CGFloat = 40

    var body: some View {
        Button(action: {
            // Toggle the beat on/off
            state.toggleBeat(instrument: instrument, at: beatPosition)
        }) {
            Circle()
                // Fill color based on enabled state
                .fill(isEnabled ? Color.blue : Color.gray.opacity(0.3))
                // Border to highlight current beat position
                .overlay(
                    Circle()
                        .stroke(isCurrentPosition ? Color.yellow : Color.clear, lineWidth: 3)
                )
                .frame(width: buttonSize, height: buttonSize)
        }
        .buttonStyle(.plain)
    }

    /// Whether this beat is enabled in the pattern
    private var isEnabled: Bool {
        state.beatPattern.isEnabled(instrument: instrument, at: beatPosition)
    }

    /// Whether this is the current playing beat position
    private var isCurrentPosition: Bool {
        state.currentBeatPosition == beatPosition
    }
}

#Preview {
    // Create a sample state for preview
    let state = SequencerState(beatCount: 16, initialBPM: 120.0)

    // Enable some sample beats to show the UI pattern
    state.toggleBeat(instrument: .kick, at: 0)
    state.toggleBeat(instrument: .kick, at: 4)
    state.toggleBeat(instrument: .kick, at: 8)
    state.toggleBeat(instrument: .kick, at: 12)

    state.toggleBeat(instrument: .snare, at: 4)
    state.toggleBeat(instrument: .snare, at: 12)

    state.toggleBeat(instrument: .hihat, at: 2)
    state.toggleBeat(instrument: .hihat, at: 6)
    state.toggleBeat(instrument: .hihat, at: 10)
    state.toggleBeat(instrument: .hihat, at: 14)

    state.toggleBeat(instrument: .clap, at: 8)

    // Set current position to show highlighting
    state.currentBeatPosition = 4

    return SequencerGridView(state: state)
}
