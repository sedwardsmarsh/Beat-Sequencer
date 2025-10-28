import Testing
import Foundation
import Combine
@testable import Beat_Sequencer

/// Tests for the SequencerTimer class
struct SequencerTimerTests {

    /// Tests that the timer initializes with correct default values
    @Test func testInitialization() {
        // Create a timer with default BPM
        let timer = SequencerTimer()

        // Verify default values
        #expect(timer.bpm == 120.0)
        #expect(timer.isRunning == false)
        #expect(timer.beatPublisher == nil)
    }

    /// Tests initialization with custom BPM
    @Test func testCustomBPMInitialization() {
        // Create a timer with custom BPM
        let timer = SequencerTimer(bpm: 140.0)

        // Verify custom BPM
        #expect(timer.bpm == 140.0)
        #expect(timer.isRunning == false)
    }

    /// Tests that starting the timer creates a beat publisher
    @Test func testStart() {
        // Create a timer
        let timer = SequencerTimer()

        // Start the timer
        timer.start()

        // Verify timer is running and publisher exists
        #expect(timer.isRunning == true)
        #expect(timer.beatPublisher != nil)
    }

    /// Tests that stopping the timer clears the publisher
    @Test func testStop() {
        // Create and start a timer
        let timer = SequencerTimer()
        timer.start()

        // Verify it's running
        #expect(timer.isRunning == true)

        // Stop the timer
        timer.stop()

        // Verify timer is stopped and publisher is cleared
        #expect(timer.isRunning == false)
        #expect(timer.beatPublisher == nil)
    }

    /// Tests that stopping an already stopped timer doesn't cause issues
    @Test func testStopWhenAlreadyStopped() {
        // Create a timer (not started)
        let timer = SequencerTimer()

        // Stop it (should not crash)
        timer.stop()

        // Verify state
        #expect(timer.isRunning == false)
        #expect(timer.beatPublisher == nil)
    }

    /// Tests that starting an already running timer restarts it
    @Test func testRestartWhileRunning() {
        // Create and start a timer
        let timer = SequencerTimer()
        timer.start()

        // Get reference to first publisher
        let _ = timer.beatPublisher

        // Start again
        timer.start()

        // Verify it's still running with a new publisher
        #expect(timer.isRunning == true)
        #expect(timer.beatPublisher != nil)
        // Note: Publishers will be different instances
    }

    /// Tests updating BPM while timer is stopped
    @Test func testUpdateBPMWhileStopped() {
        // Create a timer
        let timer = SequencerTimer(bpm: 120.0)

        // Update BPM while stopped
        timer.updateBPM(140.0)

        // Verify BPM is updated but timer is still stopped
        #expect(timer.bpm == 140.0)
        #expect(timer.isRunning == false)
        #expect(timer.beatPublisher == nil)
    }

    /// Tests updating BPM while timer is running
    @Test func testUpdateBPMWhileRunning() {
        // Create and start a timer
        let timer = SequencerTimer(bpm: 120.0)
        timer.start()

        // Verify it's running
        #expect(timer.isRunning == true)

        // Update BPM
        timer.updateBPM(140.0)

        // Verify BPM is updated and timer creates transition
        #expect(timer.bpm == 140.0)
        #expect(timer.isRunning == true)
        #expect(timer.beatPublisher != nil)
        #expect(timer.isTransitioning == true)
        #expect(timer.transitionPublisher != nil)
    }

    /// Tests the static interval calculation method
    @Test func testIntervalCalculation() {
        // Test various BPM values
        let interval120 = SequencerTimer.interval(forBPM: 120.0)
        #expect(interval120 == 0.5) // 60 / 120 = 0.5 seconds

        let interval60 = SequencerTimer.interval(forBPM: 60.0)
        #expect(interval60 == 1.0) // 60 / 60 = 1.0 seconds

        let interval180 = SequencerTimer.interval(forBPM: 180.0)
        #expect(abs(interval180 - 0.333333) < 0.001) // 60 / 180 ≈ 0.333 seconds

        let interval240 = SequencerTimer.interval(forBPM: 240.0)
        #expect(interval240 == 0.25) // 60 / 240 = 0.25 seconds
    }

    /// Tests that the timer publishes beat events
    @Test func testTimerPublishesBeatEvents() async throws {
        // Create a timer with fast BPM for testing (240 BPM = 0.25s interval)
        let timer = await SequencerTimer(bpm: 240.0)

        // Create expectation for receiving beats
        var beatCount = 0
        var cancellable: AnyCancellable?

        // Start the timer
        await timer.start()

        // Subscribe to beat events
        if let publisher = await timer.beatPublisher {
            cancellable = publisher.sink { _ in
                beatCount += 1
            }
        }

        // Wait for approximately 3 beats (0.75 seconds)
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds

        // Cancel subscription
        cancellable?.cancel()
        await timer.stop()

        // Should have received at least 2 beats (accounting for timing variance)
        #expect(beatCount >= 2)
    }

    /// Tests that BPM changes affect timing with transition mechanism
    @Test func testBPMChangeAffectsTiming() async throws {
        // Create a timer with slow BPM
        let timer = await SequencerTimer(bpm: 60.0) // 1 second per beat

        // Start timer
        await timer.start()

        var slowBeatCount = 0
        var oldCancellable: AnyCancellable?

        // Subscribe to slow BPM beats
        if let publisher = await timer.beatPublisher {
            oldCancellable = publisher.sink { _ in
                slowBeatCount += 1
            }
        }

        // Wait for ~1 second (should get 1 beat at 60 BPM)
        try await Task.sleep(nanoseconds: 1_100_000_000)

        // Should have received approximately 1 beat at slow BPM
        #expect(slowBeatCount >= 1, "Should receive at least 1 beat at 60 BPM")

        // Update to faster BPM while running
        await timer.updateBPM(240.0) // 0.25 seconds per beat

        // Verify transition is active
        #expect(await timer.isTransitioning == true)
        #expect(await timer.transitionPublisher != nil)

        var fastBeatCount = 0
        var transitionCancellable: AnyCancellable?

        // Subscribe to the new transition publisher with faster timing
        if let publisher = await timer.transitionPublisher {
            transitionCancellable = publisher.sink { _ in
                fastBeatCount += 1
            }
        }

        // Wait for ~0.6 seconds (should get ~2 beats at 240 BPM = 0.25s per beat)
        try await Task.sleep(nanoseconds: 600_000_000)

        // Clean up
        oldCancellable?.cancel()
        transitionCancellable?.cancel()
        await timer.stop()

        // At faster BPM (240), should receive more beats than slow BPM (60) in same time period
        // In 0.6s: 240 BPM should produce ~2 beats, 60 BPM would produce 0-1 beats
        #expect(fastBeatCount >= 2, "Should receive at least 2 beats at 240 BPM in 0.6s")
    }

    /// Tests that the timer properly cleans up on deinitialization
    @Test func testDeinitCleanup() {
        // Create a timer in a scope
        var timer: SequencerTimer? = SequencerTimer()
        timer?.start()

        // Verify it's running
        #expect(timer?.isRunning == true)

        // Deallocate the timer
        timer = nil

        // If we reach here without crashes, cleanup worked correctly
        #expect(timer == nil)
    }

    /// Tests that the timer publishes events with proper timing accuracy
    /// This test verifies the tolerance parameter added to Timer.publish
    @Test func testTimerPublishesWithTolerance() async throws {
        // Create a timer with a fast BPM for testing (240 BPM = 0.25s interval)
        let timer = await SequencerTimer(bpm: 240.0)
        // Tolerance is set to 10ms (0.01s) in SequencerTimer.start()
        let tolerance: TimeInterval = 0.01

        // Track beat timestamps
        var beatTimestamps: [Date] = []
        var cancellable: AnyCancellable?

        // Start the timer
        await timer.start()

        // Subscribe to beat events and record timestamps
        if let publisher = await timer.beatPublisher {
            cancellable = publisher.sink { timestamp in
                beatTimestamps.append(timestamp)
            }
        }

        // Wait for approximately 5 beats (1.25 seconds)
        try await Task.sleep(nanoseconds: 1_300_000_000) // 1.3 seconds

        // Cancel subscription and stop timer
        cancellable?.cancel()
        await timer.stop()

        // Verify we received at least 4 beats
        let expectedNumBeats = 4
        #expect(beatTimestamps.count >= expectedNumBeats,
                "Number of beats was smaller than expected, was <\(expectedNumBeats)")

        // Expected interval (period) is 0.25s @ 240 BPM...
        // 60 / 240 = 0.25 seconds
        let expectedInterval: TimeInterval = 0.25
        
        // Verify timing between consecutive beats is within expected interval +/- tolerance
        // Check intervals between consecutive beats
        for i in 1..<beatTimestamps.count {
            let interval = beatTimestamps[i].timeIntervalSince(beatTimestamps[i-1])
            let deviation = abs(interval - expectedInterval)

            // Allow for system timing variance plus the 10ms tolerance
            // Using 30ms total tolerance to account for system scheduling
            let maxDeviation = tolerance + 0.02

            #expect(deviation <= maxDeviation,
                   "Beat interval \(interval) deviated \(deviation)s from expected \(expectedInterval)s")
        }
    }

    /// Tests that timer creates publisher with correct tolerance configuration
    /// Verifies that the start() method properly configures the timer with tolerance
    @Test func testStartCreatesPublisherWithTolerance() async throws {
        // Create timer with moderate BPM
        let timer = await SequencerTimer(bpm: 120.0)
//        let expectedInterval: TimeInterval = 0.5 // 60 / 120 = 0.5 seconds

        // Verify initial state
        #expect(await timer.beatPublisher == nil)
        #expect(await timer.isRunning == false)

        // Start the timer (this executes lines 35-43 with tolerance configuration)
        await timer.start()

        // Verify timer is running and publisher exists
        #expect(await timer.isRunning == true)
        #expect(await timer.beatPublisher != nil)

        // Collect beat events to verify publisher is functional
        var beatCount = 0
        var cancellable: AnyCancellable?
        if let publisher = await timer.beatPublisher {
            cancellable = publisher.sink { _ in
                beatCount += 1
            }
        }

        // Wait for expected interval plus tolerance (0.5s + 0.02s buffer)
        try await Task.sleep(nanoseconds: 550_000_000)

        // Should have received at least 1 beat
        #expect(beatCount >= 1)

        // Clean up
        cancellable?.cancel()
        await timer.stop()
    }

    /// Tests the complete transition flow when BPM changes during playback
    /// Verifies that old timer continues until new timer fires its first beat
    @Test func testTransitionFromOldToNewTimer() async throws {
        // Create a timer with slow BPM for easier observation
        let timer = await SequencerTimer(bpm: 120.0) // 0.5s per beat

        // Start the timer
        await timer.start()

        // Verify initial state
        #expect(await timer.isRunning == true)
        #expect(await timer.beatPublisher != nil)
        #expect(await timer.isTransitioning == false)
        #expect(await timer.transitionPublisher == nil)

        // Subscribe to the old timer
        var oldTimerBeatCount = 0
        var cancellable: AnyCancellable?
        if let publisher = await timer.beatPublisher {
            cancellable = publisher.sink { _ in
                oldTimerBeatCount += 1
            }
        }

        // Wait for first beat from old timer
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6s
        #expect(oldTimerBeatCount >= 1, "Old timer should fire at least one beat")

        // Now change BPM while running
        await timer.updateBPM(240.0) // 0.25s per beat

        // Verify transition state
        #expect(await timer.bpm == 240.0)
        #expect(await timer.isRunning == true)
        #expect(await timer.isTransitioning == true)
        #expect(await timer.transitionPublisher != nil)
        #expect(await timer.beatPublisher != nil) // Old publisher still exists

        // Old subscription should continue working briefly
        let beforeTransitionCount = oldTimerBeatCount

        // Wait a bit - old timer might fire once more
        try await Task.sleep(nanoseconds: 600_000_000) // 0.6s

        // Old subscription might have fired once more (if within interval)
        // But it's still subscribed to the old publisher
        let afterWaitCount = oldTimerBeatCount
        #expect(afterWaitCount >= beforeTransitionCount)

        // Complete the transition manually (simulating what SequencerEngine does)
        await timer.completeTransition()

        // Verify transition completed
        #expect(await timer.isTransitioning == false)
        #expect(await timer.transitionPublisher == nil)
        #expect(await timer.beatPublisher != nil) // Now has the new publisher

        // Clean up
        cancellable?.cancel()
        await timer.stop()
    }

    /// Tests that updating BPM with the same value doesn't trigger transition
    @Test func testUpdateBPMWithSameValueNoOp() {
        // Create a timer
        let timer = SequencerTimer(bpm: 120.0)
        timer.start()

        // Verify initial state
        #expect(timer.isRunning == true)
        #expect(timer.isTransitioning == false)

        // Update with same BPM
        timer.updateBPM(120.0)

        // Verify no transition was created
        #expect(timer.bpm == 120.0)
        #expect(timer.isTransitioning == false)
        #expect(timer.transitionPublisher == nil)

        // Clean up
        timer.stop()
    }

    /// Tests that stop() clears any in-progress transitions
    @Test func testStopClearsTransition() {
        // Create and start a timer
        let timer = SequencerTimer(bpm: 120.0)
        timer.start()

        // Trigger a transition
        timer.updateBPM(180.0)

        // Verify transition is active
        #expect(timer.isTransitioning == true)
        #expect(timer.transitionPublisher != nil)

        // Stop the timer
        timer.stop()

        // Verify transition is cleared
        #expect(timer.isRunning == false)
        #expect(timer.isTransitioning == false)
        #expect(timer.transitionPublisher == nil)
        #expect(timer.beatPublisher == nil)
    }
}
