# User Prompts

load @SPEC.md into context

based on the info from @SPEC.md, create an architecture document called "ARCH.md" that will explain the details of implementation for the app. IMPORTANT, focus on simplicity over complexity.

As described in @SPEC.md, record my input in @PROMPTS.md. Now, following @ARCH.md, lets incrementally write the app.

Our development loop will be as follows:
1. You implement a feature with its views and functions
2. You write tests for the functions
3. I will review the code you wrote
4. After my approval, you will commit the changes to git

I approve the changes, commit these changes to git history and proceed with the TODOs. As discussed, pause after the next implementation and corresponding tests so I can review.

before proceeding, @Beat-Sequencer/Audio/AudioPlayer.swift is failing to load the audio files, review lines 34:48 to fix loading of the audio files.

the following error occurrs on lines 12, 21 and 35 of "AudioPlayerTests.swift": Caught error: .fileNotFound(instrument: Beat_Sequencer.Instrument.kick, fileName: "Lay-Down-Blackout-Kick.wav")

Before proceeding, we need to fix the audio file loading

I moved the audio files from the "instruments-audio" folder to the root directory of the project.

To simplify the bundle path, I also renamed the files to their corresponding category name. Now they are named:
"kick.wav", "clap.wav", "hihat.wav", and "snare.wav".
    - Update the Instrument enum with the correct audio file name in audioFileName().

Remove the bundle argument from AudioPlayer initialization

- Proceed to implement the SequenceTimer, write tests for the new implementation and then pause to wait for me to review the changes.

- including this prompt, From now on, when making entries to PROMPTS.md, add a new entry "-" per prompt from me. Multiline prompts should be contained on the same entry "-". Regarding the current implementation. The tests pass and implementation is maintainable. Moving forward, proceed to implement the SequencerEngine with corresponding tests, then wait for me to review the changes

- commit the changes for AudioPlayer, SequenceTimer and SequenceEngine to git history. Then proceed to final TODO, implement UI views.
