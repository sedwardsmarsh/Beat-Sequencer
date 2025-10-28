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

- create #Previews for @Beat-Sequencer/Views/ControlPanelView.swift and @Beat-Sequencer/Views/SequencerGridView.swift and @Beat-Sequencer/ContentView.swift. Add the necessary state definitions inside the #Preview block to construct each previewed component.

- commit these changes to git history

- Necessary changes are required to bring the app to a better state: 1. Reduce the sequence grid to 8 beat events wide. The current implementation runs off the right side of the screen. 2. Combine the Play and Pause buttons to a single button which updates its icon and text depending on the app running state. 3. Display BPM above the text entry box and move the set button beneath the text entry box.

- Load @PROMPTS.md for reference: As requested previously in this project, save user input into PROMPTS.md. Save this prompt into PROMPTS. 1. Based on the change made in c8d1f5f, add test coverage for SequencerTimer.start(). Specifically, add coverage for lines 35 to 43. 2. Before commiting changes to Git, pause to let me review your work. 3. After I approve your work, commit the changes to git.

- I will perform the test myself, pause now to wait for my code approval of your code. mark 2nd TODO item as complete. update @PROMPTS.md

- I'm noticed a bug in the app when I interact with the BPM textfield if the sequencer is running: the app will hang. I believe there is an issue with how the textfield is updating state.bpm. 1. Write a plan to diagnose this issue with tests first to confirm there is a glitch/slowdown if the app is running and the textfield is interacted with. Use timestamps to confirm the app hangs and does not immediately let the user input a new BPM. 2. Devise a plan to fix this issue.
