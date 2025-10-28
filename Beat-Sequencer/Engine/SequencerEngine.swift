import Foundation
import Combine

/// Coordinates the timer, audio player, and sequencer state
/// Implements the main business logic for the beat sequencer
class SequencerEngine: ObservableObject {
    /// The sequencer state (published for UI binding)
    let state: SequencerState

    /// The audio player for triggering instrument sounds
    private let audioPlayer: AudioPlayer

    /// The timer that drives beat events
    private let timer: SequencerTimer

    /// Subscription to timer beat events
    private var beatSubscription: AnyCancellable?

    /// Subscription to transition timer events during BPM changes
    private var transitionSubscription: AnyCancellable?

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
    /// Stops the timer and cancels all subscriptions
    func pause() {
        // Mark state as not playing
        state.isPlaying = false

        // Stop the timer (also clears any transitions)
        timer.stop()

        // Cancel beat subscription
        beatSubscription?.cancel()
        beatSubscription = nil

        // Cancel transition subscription if exists
        transitionSubscription?.cancel()
        transitionSubscription = nil
    }

    /// Updates the BPM (tempo) of the sequencer
    /// - Parameter newBPM: The new beats per minute value
    /// If the sequencer is playing, this will create a smooth transition to the new BPM
    func updateBPM(_ newBPM: Double) {
        // Update BPM in state
        state.updateBPM(newBPM)

        // Update BPM in timer (creates transition if running)
        timer.updateBPM(newBPM)

        // If playing, subscribe to the transition timer
        if state.isPlaying {
            subscribeToTransition()
        }
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

    /// Subscribes to the transition timer during BPM changes
    /// On the first beat from the new timer, completes the transition and re-subscribes to beat events
    private func subscribeToTransition() {
        // Cancel any existing transition subscription
        transitionSubscription?.cancel()

        // Subscribe to the transition timer's publisher
        guard let publisher = timer.transitionPublisher else { return }

        transitionSubscription = publisher.sink { [weak self] _ in
            guard let self = self else { return }

            // On first event from new timer, complete the transition
            self.timer.completeTransition()

            // Re-subscribe to the new beat publisher
            self.resubscribeToBeatEvents()

            // Cancel transition subscription as it's no longer needed
            self.transitionSubscription?.cancel()
            self.transitionSubscription = nil

            // Handle this beat normally
            self.handleBeat()
        }
    }

    /// Re-subscribes to beat events after a BPM transition
    /// Cancels old subscription and establishes new one with updated timer
    private func resubscribeToBeatEvents() {
        // Cancel existing beat subscription
        beatSubscription?.cancel()

        // Re-subscribe to the updated beat publisher
        subscribeToBeatEvents()
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
