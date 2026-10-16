# Tiny Tina's Wonderlands - Dialogue Skipper Mod (Modernized)

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Game](https://img.shields.io/badge/Game-Tiny%20Tina's%20Wonderlands-purple.svg)](https://playwonderlands.2k.com/)
[![Framework](https://img.shields.io/badge/Framework-RE--UE4SS%20%7C%20PythonSDK-brightgreen.svg)](https://github.com/bl-sdk/oak-mod-manager)
[![Version](https://img.shields.io/badge/Version-2.1.0-orange.svg)](#changelog)

A modernized, high-performance quality-of-life mod for **Tiny Tina's Wonderlands** (and compatible with **Borderlands 3**) that adds a customizable hotkey (**F6** by default) to instantly skip currently playing dialogue lines, plus an optional Fast-Forward hotkey (**F7**) to bypass slow NPC walking animations and elevator pacing stalls. Written by AI (Gemini).

---

## 📑 Table of Contents

- [Overview & Features](#-overview--features)
- [Why This Update Was Needed (2023 Mod Breakdown)](#-why-this-update-was-needed-2023-mod-breakdown)
- [Installation Guide](#-installation-guide)
  - [Method 1: RE-UE4SS (Most Common / Nexus Mods Style)](#method-1-re-ue4ss-recommended--most-common)
  - [Method 2: Oak Mod Manager (PythonSDK)](#method-2-oak-mod-manager-pythonsdk)
- [Controls & In-Game Usage](#-controls--in-game-usage)
- [Customizing Keybinds](#-customizing-keybinds)
- [How It Works (Technical Overview)](#-how-it-works-technical-overview)
- [Softlock Prevention & Best Practices](#-softlock-prevention--best-practices)
- [Credits & Acknowledgements](#-credits--acknowledgements)
- [Disclaimer & License](#-disclaimer--license)

---

## ✨ Overview & Features

- **Instant Dialogue Skipping (`F6`)**: Halts active dialogue lines immediately and marks narrative objectives as finished, advancing the quest without waiting for long voice-over speeches.
- **Fast-Forward Companion Mode (`F7`)**: Toggles 5x global time dilation (`slomo 5.0`). Perfect for sections where NPCs are slowly walking to open a door, pull a lever, or finish physical animations.
- **Dual Framework Support**: Includes ready-to-use packages for both **RE-UE4SS** (Lua) and **Oak Mod Manager** (PythonSDK).
- **Auto-Skip Support (PythonSDK)**: Option to automatically skip all non-essential chatter as soon as it begins.
- **Game Thread Safety**: All engine calls are wrapped inside main thread dispatchers to eliminate memory access violations and game crashes.

---

## 🔍 Why This Update Was Needed (2023 Mod Breakdown)

The original community dialogue-skipping mods published around 2022–2023 ceased working or caused crashes on modern game updates due to architectural shifts:

1. **UE4SS Loader Changes (`mods.txt` vs `enabled.txt`)**: Modern RE-UE4SS (v2.5.2+ and v3.0+) no longer scans for legacy `enabled.txt` markers inside mod subfolders. Mods now require an explicit registration in `Mods/mods.txt`. Without this, older mods failed to load silently.
2. **Thread Safety Crashes**: Invoking `dialog:StopPerformance()` directly from an asynchronous keybind hook causes memory access violations in modern Unreal Engine builds. This updated script wraps engine interactions in `ExecuteInGameThread()`.
3. **API Overload Desync**: Different UE4SS releases altered the signature of `RegisterKeyBind`. This release implements an adaptive fallback that gracefully detects and registers keybinds across any UE4SS version.
4. **Component Hierarchy Coverage**: Expanded component scanning targets both `GbxDialogComponent` and `OakDialogComponent` to ensure all player echoes, story NPCs, and quest objects are caught.

---

## 🚀 Installation Guide

Choose the method matching your installed modding framework:

### Method 1: RE-UE4SS (Recommended / Most Common)

*Best for players who manage mods via file drops or Nexus Mods.*

1. **Install RE-UE4SS** (if not already installed):
   - Download the latest **Xinput** release of [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS/releases).
   - Extract the contents into your game binary folder:
     - **Steam**: `...\SteamLibrary\steamapps\common\Tiny Tina's Wonderlands\OakGame\Binaries\Win64\`
     - **Epic Games**: `...\TinyTinasWonderlands\OakGame\Binaries\Win64\`
   - *(Optional)*: Copy the provided `UE4SS_Mod/OakGame/Binaries/Win64/UE4SS-settings.ini` to your `Win64\` directory to prevent annoying debug console popups on startup (`GuiConsoleEnabled = 0`).

2. **Copy the Mod**:
   - Copy the folder `UE4SS_Mod/OakGame/Binaries/Win64/Mods/DialogSkipMod` into your game's `Mods` directory:
     ```text
     <Game Path>\OakGame\Binaries\Win64\Mods\DialogSkipMod\
     ```

3. **Enable in `mods.txt`**:
   - Open `<Game Path>\OakGame\Binaries\Win64\Mods\mods.txt` in any text editor.
   - Ensure the following line is present:
     ```text
     DialogSkipMod : 1
     ```

4. **Launch the game** and press **F6** to skip dialogue!

---

### Method 2: Oak Mod Manager (PythonSDK)

*Best for players using the official Borderlands PythonSDK ecosystem.*

1. **Install Oak Mod Manager** (if not already installed):
   - Download and install [Oak Mod Manager](https://github.com/bl-sdk/oak-mod-manager/releases) into your game directory.

2. **Copy the Mod**:
   - Copy the `PythonSDK_Mod/sdk_mods/dialog_skipper` folder into your game's `sdk_mods` folder:
     ```text
     <Game Path>\OakGame\Binaries\Win64\sdk_mods\dialog_skipper\
     ```

3. **Configure Keybinds In-Game**:
   - Launch *Tiny Tina's Wonderlands*.
   - In the Main Menu, open **Mods Menu** -> **Dialog Skipper**.
   - Under **Keybinds**, map **Skip Dialog** to **`F6`** (or your preferred key).
   - *(Optional)*: Bind **Fast Forward (Toggle)** to **`F7`**.
   - *(Optional)*: Toggle **Auto Skip** to `Enabled` for automatic dialogue skipping.
4. **Restart the game once** to finalize Python hook registration.

---

## 🎮 Controls & In-Game Usage

| Key | Action | Description |
| :---: | :--- | :--- |
| **`F6`** | **Skip Active Dialogue** | Immediately stops the active dialogue thread and signals quest scripts to proceed to the next stage. |
| **`F7`** | **Fast-Forward Toggle (5x)** | Speeds up global game time (`slomo 5.0`). Use this when an NPC is slowly walking to open a gate or trigger an animation. Press again to return to normal speed (`slomo 1.0`). |

---

## ⚙️ Customizing Keybinds

### In the RE-UE4SS (Lua) Version:
1. Open `OakGame\Binaries\Win64\Mods\DialogSkipMod\Scripts\main.lua` in any text editor.
2. Edit the `CONFIG` table at the top:
   ```lua
   local CONFIG = {
       SkipKey = Key.F6,          -- Change to Key.F1, Key.Z, Key.Space, etc.
       FastForwardKey = Key.F7,   -- Change to your desired speedup key
       FastForwardSpeed = 5.0,    -- Speed multiplier (e.g. 3.0, 5.0, 8.0)
       EnableFastForward = true,
       LogToConsole = true
   }
   ```
3. Save the file. Changes take effect on next game launch.

### In the PythonSDK Version:
Keybinds are remappable directly from the in-game UI via **Main Menu > Mods > Dialog Skipper > Keybinds**.

---

## 🔬 How It Works (Technical Overview)

Gearbox's Unreal Engine framework ("Oak") manages character voice-overs, echo transmissions, and NPC chatter through `GbxDialogComponent`.

When an NPC speaks:
1. The dialogue subsystem allocates a unique `DialogThreadID` tracked in `GbxDialogComponent.CurrentPerformance`.
2. When the skip key is pressed, the mod iterates through active loaded dialog components, verifies `DialogThreadID > 0`, and invokes:
   ```lua
   dialogComp:StopPerformance(threadId, true)
   ```
3. Passing `true` as the completion flag signals to the underlying mission script that the line finished cleanly, advancing the mission trigger without stalling.
4. For animation-locked sequences without active dialogue threads, the companion Fast-Forward utility adjusts `WorldSettings.TimeDilation` (`slomo`) to quickly pass physical delays without breaking physics.

---

## 🛡️ Softlock Prevention & Best Practices

- **Allow NPCs to Reach Destination Triggers**: Some quests require an NPC to step inside a physical trigger volume (e.g., reaching a catapult or door) before spawning the next objective. If you skip dialogue and an NPC is still walking, toggle **`F7` (Fast Forward)** to let them arrive quickly rather than repeatedly spamming skip.
- **Interactive Cutscenes**: During heavy in-engine scripted sequences, let the game transition cleanly into the gameplay state before skipping subsequent dialogue lines.

---

## 🏆 Credits & Acknowledgements

This mod builds upon and modernizes the hard work of pioneers in the *Borderlands* and Unreal Engine modding communities:

- **[RuthlessGrimm (Grimm)](https://www.nexusmods.com/borderlands3/users/83783933)**: Creator of the original *Dialog Skipper* mod for *Borderlands 3* and *Tiny Tina's Wonderlands* on Nexus Mods, who demonstrated the initial UE4SS proof-of-concept for skipping dialogue via hotkey.
- **[apple1417](https://github.com/apple1417)**: Author of the PythonSDK implementation of `dialog_skipper` in `oak-sdk-mods`, creator of `OpenHotfixLoader`, and primary architect behind `pyunrealsdk` and modern Borderlands SDK infrastructure.
- **[bl-sdk Community & ZetaDaemon](https://github.com/bl-sdk)**: Maintainers of the Borderlands Python SDK ecosystem, mod databases (`oak-mod-db`, `willow2-mod-db`), and `oak-mod-manager`.
- **[The RE-UE4SS Team](https://github.com/UE4SS-RE/RE-UE4SS)**: Developers of the Unreal Engine 4/5 Scripting System, which makes runtime Lua scripting and object reflection possible.
- **[Gearbox Software](https://www.gearboxsoftware.com/) & [2K Games](https://www.2k.com/)**: Creators and publishers of *Tiny Tina's Wonderlands* and the *Borderlands* series.

---

## 📄 Disclaimer & License

- **License**: This project is licensed under the [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0).
- **Disclaimer**: This is an unofficial, community-made modification. It is not affiliated with, endorsed by, or supported by Gearbox Software or 2K Games. Use at your own discretion. Always keep periodic backups of your save files located in `%USERPROFILE%\Saved Games\Tiny Tina's Wonderlands\Saved\SaveGames\`.
