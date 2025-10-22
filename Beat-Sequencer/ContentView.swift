//
//  ContentView.swift
//  Beat-Sequencer
//
//  Created by Sam Edwards-Marsh on 10/22/25.
//

import SwiftUI

/// Main view for the beat sequencer application
/// Owns the sequencer engine and displays control panel and grid
struct ContentView: View {
    /// The sequencer engine that coordinates all components
    @StateObject private var engine: SequencerEngine

    /// Initializes the content view and creates the sequencer engine
    init() {
        // Create the engine (using _StateObject for proper initialization)
        // If engine creation fails, the app will crash with descriptive error
        _engine = StateObject(wrappedValue: {
            do {
                return try SequencerEngine()
            } catch {
                fatalError("Failed to initialize SequencerEngine: \(error)")
            }
        }())
    }

    var body: some View {
        VStack(spacing: 20) {
            // Title
            Text("Beat Sequencer")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            // Control panel (play, pause, BPM)
            ControlPanelView(engine: engine, state: engine.state)

            // Sequencer grid (beat buttons)
            SequencerGridView(state: engine.state)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
