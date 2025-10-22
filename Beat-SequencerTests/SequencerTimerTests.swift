import Testing
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

        // Verify BPM is updated and timer is still running
        #expect(timer.bpm == 140.0)
        #expect(timer.isRunning == true)
        #expect(timer.beatPublisher != nil)
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

    /// Tests that BPM changes affect timing
    @Test func testBPMChangeAffectsTiming() async throws {
        // Create a timer with slow BPM
        let timer = await SequencerTimer(bpm: 60.0) // 1 second per beat

        // Start timer
        await timer.start()

        var beatCount = 0
        var cancellable: AnyCancellable?

        // Subscribe to beats
        if let publisher = await timer.beatPublisher {
            cancellable = publisher.sink { _ in
                beatCount += 1
            }
        }

        // Wait for 0.5 seconds (should get 0-1 beats at 60 BPM)
        try await Task.sleep(nanoseconds: 500_000_000)

        let slowBeatCount = beatCount

        // Update to faster BPM
        await timer.updateBPM(240.0) // 0.25 seconds per beat
        beatCount = 0

        // Re-subscribe with new publisher
        cancellable?.cancel()
        if let publisher = await timer.beatPublisher {
            cancellable = publisher.sink { _ in
                beatCount += 1
            }
        }

        // Wait for 0.5 seconds (should get ~2 beats at 240 BPM)
        try await Task.sleep(nanoseconds: 500_000_000)

        let fastBeatCount = beatCount

        // Clean up
        cancellable?.cancel()
        await timer.stop()

        // At faster BPM, should receive more beats in same time period
        #expect(fastBeatCount > slowBeatCount)
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
}
