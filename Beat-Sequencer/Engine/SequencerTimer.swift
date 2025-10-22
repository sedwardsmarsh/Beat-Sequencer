import Foundation
import Combine

/// Central timing coordinator for the beat sequencer
/// Publishes beat events at regular intervals based on BPM
class SequencerTimer {
    /// Publisher that emits beat events at the configured interval
    private(set) var beatPublisher: AnyPublisher<Date, Never>?

    /// Cancellable reference to the timer subscription
    private var timerCancellable: AnyCancellable?

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

        // Create a timer publisher that fires at the calculated interval
        // RunLoop.main ensures timer fires on the main thread
        // .autoconnect() starts the timer immediately
        let publisher = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .eraseToAnyPublisher()

        // Store the publisher
        beatPublisher = publisher

        // Mark as running
        isRunning = true
    }

    /// Stops the timer
    /// Cancels the current timer subscription
    func stop() {
        // Cancel the timer subscription
        timerCancellable?.cancel()
        timerCancellable = nil

        // Clear the publisher
        beatPublisher = nil

        // Mark as not running
        isRunning = false
    }

    /// Updates the BPM and restarts the timer if it was running
    /// - Parameter newBPM: The new beats per minute value
    func updateBPM(_ newBPM: Double) {
        // Store the old running state
        let wasRunning = isRunning

        // Update the BPM
        self.bpm = newBPM

        // If the timer was running, restart it with the new BPM
        if wasRunning {
            start()
        }
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
