import Foundation
import Combine

/// Central timing coordinator for the beat sequencer
/// Publishes beat events at regular intervals based on BPM
class SequencerTimer {
    /// Publisher that emits beat events at the configured interval
    private(set) var beatPublisher: AnyPublisher<Date, Never>?

    /// Publisher for the new timer during BPM transitions
    /// Holds the new timer while the old timer continues running
    private(set) var transitionPublisher: AnyPublisher<Date, Never>?

    /// Whether the timer is currently transitioning to a new BPM
    private(set) var isTransitioning: Bool = false

    /// The current beats per minute (tempo)
    private(set) var bpm: Double

    /// Whether the timer is currently running
    private(set) var isRunning: Bool = false

    /// Initializes a new sequencer timer with the specified BPM
    /// - Parameter bpm: The beats per minute (default: 120.0)
    init(bpm: Double = 120.0) {
        self.bpm = bpm
    }

    /// Starts the timer with the current BPM
    /// Creates a new timer publisher that fires at intervals based on BPM
    func start() {
        // Stop any existing timer first
        stop()

        // Calculate the interval between beats in seconds
        // interval = 60 seconds / beats per minute
        let interval = 60.0 / bpm
        
        // Set the timing interval to be 10ms.
        let tolerance_S: TimeInterval? = 0.01

        // Create a timer publisher that fires at the calculated interval
        // RunLoop.main ensures timer fires on the main thread
        // .autoconnect() starts the timer immediately
        let publisher = Timer.publish(every: interval, tolerance: tolerance_S, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()

        // Store the publisher
        beatPublisher = publisher

        // Mark as running
        isRunning = true
    }

    /// Stops the timer
    /// Clears the publisher and any transition in progress
    func stop() {
        // Clear the publisher (autoconnect publishers clean up automatically)
        beatPublisher = nil

        // Clear any transition in progress
        transitionPublisher = nil
        isTransitioning = false

        // Mark as not running
        isRunning = false
    }

    /// Updates the BPM and handles timer transition if running
    /// - Parameter newBPM: The new beats per minute value
    /// If the timer is running, creates a transition timer that will replace the current timer
    /// If the timer is stopped, just updates the BPM value
    func updateBPM(_ newBPM: Double) {
        // Check if BPM actually changed to avoid unnecessary work
        guard newBPM != self.bpm else { return }

        // Update the BPM
        self.bpm = newBPM

        // If not running, just update the BPM value
        guard isRunning else { return }

        // If running, create a new timer publisher for transition
        // Calculate the interval for the new BPM
        let interval = 60.0 / newBPM

        // Set the timing tolerance to 10ms
        let tolerance_S: TimeInterval? = 0.01

        // Create the new timer publisher
        let publisher = Timer.publish(every: interval, tolerance: tolerance_S, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()

        // Store as transition publisher
        transitionPublisher = publisher

        // Mark as transitioning
        isTransitioning = true
    }

    /// Completes the transition from old timer to new timer
    /// Swaps the transition publisher into the main beat publisher
    /// Called by SequencerEngine when the first beat from the new timer fires
    func completeTransition() {
        // Swap the transition publisher into the main publisher
        beatPublisher = transitionPublisher

        // Clear the transition publisher
        transitionPublisher = nil

        // Mark transition as complete
        isTransitioning = false
    }

    /// Calculates the interval in seconds for a given BPM
    /// - Parameter bpm: The beats per minute
    /// - Returns: The interval in seconds between beats
    static func interval(forBPM bpm: Double) -> TimeInterval {
        return 60.0 / bpm
    }

    /// Deinitializer ensures the timer is stopped when the object is deallocated
    deinit {
        stop()
    }
}
