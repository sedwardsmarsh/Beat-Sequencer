# Specification Document

## Summary

1. This document outlines the project structure for a simple beat sequencing iOS app
   1. The app will utilize a central timer to coordinate a beat events
   2. IMPORTANT The app must be performant and realtime, to prevent glitches and skips during playback
      1. The app should not hang or wait for any audio to finish playing before proceeding to the next beat in the sequence
   3. Functions should be small and require low mental overhead
      1. Docstrings must be written for each function
   4. All functions must have a corresponding Swifttest

## Tech Stack

1. A file called PROMPTS.md will contain each input from the user given to claude-code.
   1. IMPORTANT Only the user input will be contained, NOT the responses from claude-code
2. The app will be written in Swift and utilize the SwiftUI framework
3. Git will be used for version control
4. Audio files for each row of the user interface will be provided in the folder "instrument-audio"

## User Interface

1. Above the sequencing grid a control panel, organized in an `HStack`
   1. A play button
      1. To start the centralized timer
   2. A pause button
      1. To stop the centralized timer
   3. A text entry box for BPM 
      1. To set the seconds per beat of the centralized timer
2. Below the control panel, A grid of circle buttons for sequencing beat events
   1. Each row corresponds to a different audio file
      1. Before each row, text describes one of the following categories the row will sequence/play, 1 of:
         1. kick, clap, snare, hihat
      2. Inside each row, circle buttons to enable/disable playback for the category at the corresponding beat event
   2. Each column corresponds to a different timestep/beat event, coordinated by the central timer
