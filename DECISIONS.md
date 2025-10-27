# Summary of Decisions

- 10-27-25 13:21 PST

  - I've replaced the TextField entry with a Stepper view to prevent the lag experienced when the user changes the BPM.
  - Now I'm focusing on enabling BPM to be changed while the app is running.
    - There are two approaches I'd like to try for this issue:
      1. Minimal changes to architecture and calling `SequencerTimer.updateBPM()`
      2. Changing `SequencerTimer.bpm` to be a `@Binding` of `ControlPanelView.bpmStepper`

- 10-24-25 14:51 PST

  - Fixed issue preventing buffers from interrupting currently playing buffers.
    - This also fixed the problem preventing consistent timing for very high BPMs (>=200)
  - Now, I'd like to focus on fixing the issue causing a temporary freeze when the BPM text box is touched while the sequencer is running.
    - This issue is more noticeable on a physical device. I confirmed this by testing on my iPhone 17 Pro.

- 10-23-25 15:49 PST

  - Another issue I noticed is that updating BPM while the app is running causes glitches in the audio playback.

- 10-23-25 12:09 PST

  - Shifting focus to improving existing issues as mentioned in [README](./README.md#todo) on 10-22-25:
    - Audio playback continues after stopping sequencer for higher BPMs (>= 200)
    - the timing of the app is inconsistent for high BPM (>= 200)
  - Continuing priorities of:
    - SWD best practices by verifying each fn with _covering_ test cases
    - Limiting scope of GenAI agent to prevent bloat and slop with controlled prompts

- 10-22-25
  - Prioritizing software development best practices by verifying functionality of each function with convering test cases
  - Focusing on creating a running app for further discussion:
    - What functionality can be added to app?
    - What are known issues with the app?
  - Focusing on limiting scope of GenAI agent to prevent bloat and slop with controlled prompts
  - Decided to move audio files to root directory to prevent path issues with bundle
