# Summary of Decisions

- 10-23-25 15:49 PST
  - Another issue I noticed is that updating BPM while the app is running causes glitches in the audio playback.

- 10-23-25 12:09 PST
  - Shifting focus to improving existing issues as mentioned in [README](./README.md#todo) on 10-22-25:
      - Audio playback continues after stopping sequencer for higher BPMs (>= 200)
      - the timing of the app is inconsistent for high BPM (>= 200)
  - Continuing priorities of:
    - SWD best practices by verifying each fn with *covering* test cases
    - Limiting scope of GenAI agent to prevent bloat and slop with controlled prompts

- 10-22-25
  - Prioritizing software development best practices by verifying functionality of each function with convering test cases
  - Focusing on creating a running app for further discussion:
    - What functionality can be added to app?
    - What are known issues with the app?
  - Focusing on limiting scope of GenAI agent to prevent bloat and slop with controlled prompts
  - Decided to move audio files to root directory to prevent path issues with bundle
