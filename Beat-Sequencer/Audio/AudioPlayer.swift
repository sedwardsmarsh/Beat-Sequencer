import Foundation
import AVFoundation

/// Manages audio playback for the beat sequencer
/// Uses AVAudioEngine with pre-loaded buffers for zero-latency playback
class AudioPlayer {
    /// The audio engine that manages audio processing graph
    private let engine = AVAudioEngine()

    /// Player nodes for each instrument (one per instrument for simultaneous playback)
    private var playerNodes: [Instrument: AVAudioPlayerNode] = [:]

    /// Pre-loaded audio buffers for each instrument
    private var audioBuffers: [Instrument: AVAudioPCMBuffer] = [:]

    /// Whether the audio engine is currently running
    private(set) var isEngineRunning = false

    /// Initializes the audio player and pre-loads all instrument audio files
    /// - Throws: Error if audio files cannot be loaded or engine cannot start
    init() throws {
        // Pre-load all audio files during initialization
        try loadAudioFiles()

        // Set up the audio engine
        setupAudioEngine()

        // Start the audio engine
        try startEngine()
    }

    /// Loads all audio files from the bundle into memory
    /// - Throws: Error if any audio file cannot be found or loaded
    private func loadAudioFiles() throws {
        // Iterate through all instruments and load their audio files
        for instrument in Instrument.allCases {
            // Get the audio file name for this instrument
            let fileName = instrument.audioFileName

            // Remove file extension for Bundle.main.url forResource parameter
            let resourceName = fileName.replacingOccurrences(of: ".wav", with: "")

            // Find the audio file in the bundle
            guard let fileURL = Bundle.main.url(
                forResource: resourceName,
                withExtension: "wav"
            ) else {
                throw AudioPlayerError.fileNotFound(instrument: instrument, fileName: fileName)
            }

            // Load the audio file into a buffer
            let audioFile = try AVAudioFile(forReading: fileURL)
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: audioFile.processingFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                throw AudioPlayerError.bufferCreationFailed(instrument: instrument)
            }

            // Read the entire file into the buffer
            try audioFile.read(into: buffer)

            // Store the buffer for later playback
            audioBuffers[instrument] = buffer
        }
    }

    /// Sets up the audio engine by creating and connecting player nodes
    private func setupAudioEngine() {
        // Create a player node for each instrument
        for instrument in Instrument.allCases {
            // Create a new player node
            let playerNode = AVAudioPlayerNode()

            // Attach the node to the engine
            engine.attach(playerNode)

            // Get the audio buffer format
            guard let buffer = audioBuffers[instrument] else { continue }

            // Connect the player node to the engine's main mixer
            engine.connect(
                playerNode,
                to: engine.mainMixerNode,
                format: buffer.format
            )

            // Store the player node
            playerNodes[instrument] = playerNode
        }
    }

    /// Starts the audio engine
    /// - Throws: Error if engine cannot start
    private func startEngine() throws {
        // Prepare the engine for playback
        engine.prepare()

        // Start the engine
        try engine.start()

        // Mark engine as running
        isEngineRunning = true

        // Start all player nodes
        for playerNode in playerNodes.values {
            playerNode.play()
        }
    }

    /// Plays the audio sample for the specified instrument
    /// This is a non-blocking, fire-and-forget method
    /// - Parameter instrument: The instrument to play
    func play(instrument: Instrument) {
        // Get the player node for this instrument
        guard let playerNode = playerNodes[instrument],
              let buffer = audioBuffers[instrument] else {
            return
        }

        // Schedule the buffer for immediate playback
        // The buffer plays from the beginning and completes automatically
        // Using nil for options allows the buffer to play without waiting
        playerNode.scheduleBuffer(buffer, at: nil, options: [], completionHandler: nil)
    }

    /// Stops the audio engine and all playback
    func stop() {
        // Stop all player nodes
        for playerNode in playerNodes.values {
            playerNode.stop()
        }

        // Stop the engine
        engine.stop()

        // Mark engine as not running
        isEngineRunning = false
    }
}

/// Errors that can occur during audio player operations
enum AudioPlayerError: Error, LocalizedError {
    /// The audio file for an instrument could not be found
    case fileNotFound(instrument: Instrument, fileName: String)

    /// Failed to create an audio buffer for an instrument
    case bufferCreationFailed(instrument: Instrument)

    /// Returns a user-friendly error description
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let instrument, let fileName):
            return "Audio file '\(fileName)' not found for instrument '\(instrument.displayName)'"
        case .bufferCreationFailed(let instrument):
            return "Failed to create audio buffer for instrument '\(instrument.displayName)'"
        }
    }
}
