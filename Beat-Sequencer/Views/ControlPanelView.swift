import SwiftUI

/// Control panel for playback and tempo controls
/// Contains play, pause, and BPM input controls
struct ControlPanelView: View {
    /// The sequencer engine to control
    let engine: SequencerEngine

    /// The sequencer state (observed for UI updates)
    @ObservedObject var state: SequencerState

    /// BPM value
    @State private var bpmStepper: Int = 120
    private let bpmStep = 1
    private let bpmMin = 40  // Match SequencerState clamping range
    private let bpmMax = 240  // Match SequencerState clamping range

    var body: some View {
        HStack(spacing: 20) {
            // Play/Pause toggle button
            Button(action: {
                // Toggle playback state
                if state.isPlaying {
                    engine.pause()
                } else {
                    engine.start()
                }
            }) {
                // Label with dynamic icon and text based on state
                Label(
                    state.isPlaying ? "Pause" : "Play",
                    systemImage: state.isPlaying ? "pause.fill" : "play.fill"
                )
                .frame(width:80)
                .padding()
                .background(state.isPlaying ? Color.red : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            bpmStepperControl
            
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    /// View for the BPM stepper control
    var bpmStepperControl: some View {
        VStack(spacing: 8) {
            // Label for BPM
            Text("BPM")
                .font(.system(size: 30, weight: .medium))
            
            // BPM stepper control
            Stepper(
                "\(bpmStepper)",
                value: $bpmStepper,
                in: bpmMin...bpmMax,
                step: bpmStep
            )
            .font(.system(size: 20, weight: .bold))
            .frame(width: 140)
            .padding(5)
            .onChange(of: bpmStepper) {
                engine.updateBPM(Double(bpmStepper))
            }
        }
        .background(.gray.opacity(0.1))
        .cornerRadius(12)
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
