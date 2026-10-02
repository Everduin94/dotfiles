/// <reference types="@raycast/api">

/* 🚧 🚧 🚧
 * This file is auto-generated from the extension's manifest.
 * Do not modify manually. Instead, update the `package.json` file.
 * 🚧 🚧 🚧 */

/* eslint-disable @typescript-eslint/ban-types */

type ExtensionPreferences = {}

/** Preferences accessible in all the extension's commands */
declare type Preferences = ExtensionPreferences

declare namespace Preferences {
  /** Preferences accessible in the `voice-prompt` command */
  export type VoicePrompt = ExtensionPreferences & {
  /** Python Binary - Absolute path to the Python executable that can run your whisper script. */
  "pythonBin": string,
  /** Whisper Script Path - Absolute path to faster-whisper.py. */
  "scriptPath": string
}
}

declare namespace Arguments {
  /** Arguments passed to the `voice-prompt` command */
  export type VoicePrompt = {}
}

