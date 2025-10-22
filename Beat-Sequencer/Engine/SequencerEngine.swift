import Foundation
import Combine

/// Coordinates the timer, audio player, and sequencer state
/// Implements the main business logic for the beat sequencer
class SequencerEngine {
    /// The sequencer state (published for UI binding)
    let state: SequencerState

    /// The audio player for triggering instrument sounds
    private let audioPlayer: AudioPlayer

    /// The timer that drives beat events
    private let timer: SequencerTimer

    /// Subscription to timer beat events
    private var beatSubscription: AnyCancellable?

    /// Initializes the sequencer engine with required components
    /// - Parameters:
    ///   - state: The sequencer state (defaults to new instance)
    ///   - audioPlayer: The audio player (will create if not provided)
    ///   - timer: The timer (defaults to new instance with state's BPM)
    /// - Throws: Error if audio player creation fails
    init(state: SequencerState = SequencerState(), audioPlayer: AudioPlayer? = nil, timer: SequencerTimer? = nil) throws {
        // Store the state
        self.state = state

        // Create or use provided audio player
        if let player = audioPlayer {
            self.audioPlayer = player
        } else {
            self.audioPlayer = try AudioPlayer()
        }

        // Create or use provided timer with state's BPM
        if let existingTimer = timer {
            self.timer = existingTimer
        } else {
            self.timer = SequencerTimer(bpm: state.bpm)
        }
    }

    /// Starts the sequencer playback
    /// Begins the timer and subscribes to beat events
    func start() {
        // Mark state as playing
        state.isPlaying = true

        // Start the timer
        timer.start()

        // Subscribe to beat events
        subscribeToBeatEvents()
    }

    /// Pauses the sequencer playback
    /// Stops the timer and cancels beat subscription
    func pause() {
        // Mark state as not playing
        state.isPlaying = false

        // Stop the timer
        timer.stop()

        // Cancel beat subscription
        beatSubscription?.cancel()
        beatSubscription = nil
    }

    /// Updates the BPM (tempo) of the sequencer
    /// - Parameter newBPM: The new beats per minute value
    func updateBPM(_ newBPM: Double) {
        // Update BPM in state
        state.updateBPM(newBPM)

        // Update BPM in timer (will restart if running)
        timer.updateBPM(newBPM)
    }

    /// Subscribes to timer beat events and handles each beat
    private func subscribeToBeatEvents() {
        // Cancel any existing subscription
        beatSubscription?.cancel()

        // Subscribe to the timer's beat publisher
        guard let publisher = timer.beatPublisher else { return }

        beatSubscription = publisher.sink { [weak self] _ in
            self?.handleBeat()
        }
    }

    /// Handles a single beat event
    /// Plays enabled instruments and advances the beat position
    private func handleBeat() {
        // Get the current beat position from state
        let currentPosition = state.currentBeatPosition

        // Get all enabled instruments at this position
        let enabledInstruments = state.beatPattern.enabledInstruments(at: currentPosition)

        // Play audio for each enabled instrument (non-blocking)
        for instrument in enabledInstruments {
            audioPlayer.play(instrument: instrument)
        }

        // Advance to the next beat position
        state.advanceBeat()
    }

    /// Resets the sequencer to the beginning of the pattern
    func reset() {
        // Stop playback
        pause()

        // Reset position to start
        state.resetPosition()
    }

    /// Deinitializer ensures proper cleanup
    deinit {
        // Cancel subscription
        beatSubscription?.cancel()

        // Stop the timer
        timer.stop()
    }
}
