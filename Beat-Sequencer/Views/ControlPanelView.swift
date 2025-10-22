import SwiftUI

/// Control panel for playback and tempo controls
/// Contains play, pause, and BPM input controls
struct ControlPanelView: View {
    /// The sequencer engine to control
    let engine: SequencerEngine

    /// The sequencer state (observed for UI updates)
    @ObservedObject var state: SequencerState

    /// Local BPM text field value
    @State private var bpmText: String = ""

    var body: some View {
        HStack(spacing: 20) {
            // Play button
            Button(action: {
                // Start playback
                engine.start()
            }) {
                // Label with play icon and text
                Label("Play", systemImage: "play.fill")
                    .padding()
                    .background(state.isPlaying ? Color.green.opacity(0.3) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            // Disable if already playing
            .disabled(state.isPlaying)

            // Pause button
            Button(action: {
                // Pause playback
                engine.pause()
            }) {
                // Label with pause icon and text
                Label("Pause", systemImage: "pause.fill")
                    .padding()
                    .background(state.isPlaying ? Color.red : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            // Disable if not playing
            .disabled(!state.isPlaying)

            // BPM text field
            HStack {
                // Label for BPM
                Text("BPM:")
                    .font(.headline)

                // Text field for entering BPM
                TextField("120", text: $bpmText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                    .keyboardType(.numberPad)
                    // Update engine when user commits (presses return)
                    .onSubmit {
                        updateBPM()
                    }
                    // Initialize with current BPM on appear
                    .onAppear {
                        bpmText = String(format: "%.0f", state.bpm)
                    }
                    // Update text when state BPM changes
                    .onChange(of: state.bpm) { oldValue, newValue in
                        bpmText = String(format: "%.0f", newValue)
                    }

                // Button to apply BPM change
                Button("Set") {
                    updateBPM()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    /// Updates the BPM from the text field
    private func updateBPM() {
        // Parse the BPM from text
        if let newBPM = Double(bpmText) {
            // Update the engine with new BPM
            engine.updateBPM(newBPM)
        } else {
            // Reset to current BPM if invalid
            bpmText = String(format: "%.0f", state.bpm)
        }
    }
}

#Preview {
    // Create a sample state for preview
    let state = SequencerState(initialBPM: 120.0)

    // Create a sample engine for preview
    // Note: Audio playback won't work in preview, but UI will render
    let engine = try! SequencerEngine(state: state)

    return ControlPanelView(engine: engine, state: state)
}
