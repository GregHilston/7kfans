# Seven Kingdoms: Ancient Adversaries - Build Instructions for macOS

This repository contains a Nix flake that provides an isolated development environment for building Seven Kingdoms: Ancient Adversaries from source on macOS.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- macOS (tested on macOS with Apple Silicon)

## Getting the Source Code and Music

1. Download the official source code from **https://7kfans.com/download/**
2. Download the music files from **https://7kfans.com/download/** (e.g., `7kaa-music-2.15.tar.bz2`)
3. Extract the downloaded source archive (e.g., `7kaa-2.15.6.tar.gz`)
4. Copy the `flake.nix` file from this repository into the extracted source directory

## Build Instructions

### Step 1: Enter the Nix Development Shell

Navigate to the extracted source directory and enter the development environment:

```bash
cd path/to/7kaa-2.15.6  # Replace with your actual path
nix develop
```

This will download and set up all necessary build dependencies including:
- GCC compiler
- GNU Make and autotools
- SDL2 development libraries
- OpenAL audio library
- enet networking library
- All required headers and build tools

### Step 2: Fix a Small Compilation Issue

There's a minor issue with the source code on macOS that needs to be fixed. Edit the file `src/LocaleRes.cpp`:

```bash
# Edit src/LocaleRes.cpp and add the following after line 28:
#ifdef HAVE_LC_MESSAGES
#include <locale.h>
#endif
```

The file should look like this around lines 24-32:
```cpp
#include <stdlib.h>
#ifdef ENABLE_NLS
#include <libintl.h>
#include <locale.h>
#endif
#ifdef HAVE_LC_MESSAGES
#include <locale.h>
#endif
```

### Step 3: Configure the Build

Run the configure script with the proper environment variables (these are automatically set in the Nix shell):

```bash
export CPPFLAGS="-I/nix/store/.../sdl2-compat-.../include/SDL2"
export LDFLAGS="-L/nix/store/.../sdl2-compat-.../lib"
./configure
```

**Note:** The exact paths will be different in your environment. The Nix shell automatically sets up the correct paths, so you can simply run:

```bash
./configure
```

### Step 4: Build the Game

Compile the game using make:

```bash
make -j4
```

This will build the game using 4 parallel jobs. Adjust the number based on your CPU cores.

### Step 5: Install Music Files (Optional but Recommended)

To enjoy the original game music, install the music files:

1. Extract the music archive:
   ```bash
   tar -xf ~/Downloads/7kaa-music-2.15.tar.bz2 -C ~/Downloads/
   ```

2. Copy the music files to the game data directory:
   ```bash
   cp -r ~/Downloads/7kaa-music/MUSIC data/
   ```

3. Verify the music files are in place:
   ```bash
   ls data/MUSIC/
   ```
   You should see `.WAV` files including `WAR.WAV`, `WIN.WAV`, `LOSE.WAV`, and various civilization themes.

### Step 6: Run the Game

Once the build completes successfully, you can run the game. **Important:** You must run the game from within the Nix development shell to ensure all dependencies (SDL2, OpenAL, etc.) are available.

```bash
# Make sure you're in the Nix development shell
nix develop

# Launch the game
SKDATA=data src/7kaa
```

**Quick launch method:**
```bash
cd path/to/7kaa-2.15.6
nix develop
SKDATA=data src/7kaa
```

If you installed the music files, you should hear the WAR.WAV track playing at the main menu.

**Note:** The game requires the Nix shell environment to run properly. If you try to run `src/7kaa` outside of `nix develop`, you may encounter library linking errors.

## Game Configuration

### Window Size and Display Settings

The game can be configured by creating a `config.txt` file in the game directory and/or in `~/Library/Application Support/7kfans.com/7kaa/config.txt`. The following settings are available:

#### Window Size Configuration
```
vga_allow_highdpi = false
vga_keep_aspect_ratio = true
vga_full_screen = false
vga_window_width = 1515
vga_window_height = 910
```

**Window Size Adjustment:**
- `vga_window_width` - Set the window width in pixels (default game logical size is 800)
- `vga_window_height` - Set the window height in pixels (default game logical size is 600)
- Recommended sizes for modern displays: 1400-1600 width, 900-1000 height
- For larger displays, try: 1515x910 (works well on 13-16" laptops)

#### Display Options
- `vga_full_screen = true/false` - Enable/disable fullscreen mode
- `vga_keep_aspect_ratio = true/false` - Maintain 4:3 aspect ratio when scaling
- `vga_allow_highdpi = false` - **Important:** Keep this false to avoid cursor issues on Retina displays

### Retina Display Fix (macOS)

**Important for Mac users with Retina displays:** This build includes fixes for cursor movement issues on high-DPI displays. If you experience problems where the mouse cursor cannot reach the edges of the game window:

1. Ensure `vga_allow_highdpi = false` in your config file
2. Use windowed mode rather than fullscreen: `vga_full_screen = false`
3. The game has been patched to use SDL's native coordinate handling for proper Retina support

### Audio Configuration

The game uses OpenAL for audio on macOS. If you experience audio issues, you can try:
- Checking system audio settings
- Ensuring the music files are in the correct format (WAV, uppercase names)
- Verifying the data/MUSIC directory exists and contains the music files

## Build Environment Details

The Nix flake provides:

- **C++ Compiler:** GCC with C++11 support
- **Build System:** GNU Make with autotools (autoconf, automake, libtool)
- **Graphics:** SDL2 with development headers
- **Audio:** OpenAL (uses macOS system framework)
- **Networking:** enet library for multiplayer support
- **Utilities:** pkg-config, gettext for localization

## Troubleshooting

### Build Issues

#### SDL2 Not Found
If you encounter SDL2 detection issues, ensure you're running inside the `nix develop` shell where all environment variables are properly set.

#### Compilation Errors
Make sure you've applied the LocaleRes.cpp fix mentioned in Step 2.

#### Permission Issues
Ensure the source files are writable and you have proper permissions in the extracted directory.

### Runtime Issues

#### Game Won't Start
- Make sure you're running `nix develop` first before launching the game
- Verify you're in the correct directory (`cd path/to/7kaa-2.15.6`)
- Check that `src/7kaa` executable exists and is executable

#### Library Linking Errors
If you see errors like "dyld: Library not loaded", you're likely running the game outside of the Nix shell:
```bash
# Solution: Always run from within nix develop
nix develop
SKDATA=data src/7kaa
```

#### No Sound/Music
- Verify music files are in `data/MUSIC/` directory
- Check your system audio settings and volume
- Ensure OpenAL is working (test with other audio applications)

#### Cursor Cannot Reach Screen Edges (Retina Displays)
This is a known issue that has been fixed in this build. If you still experience cursor problems:
- Ensure `vga_allow_highdpi = false` in your config.txt
- Use windowed mode instead of fullscreen
- Verify the source code includes the Retina display patches (modified mouse coordinate handling)

#### Config File Parse Errors
If you see "Error in config.txt at line X":
- Ensure boolean values use `true` or `false` (not `0` or `1`)
- Check that each line follows the format: `setting_name = value`
- Verify there are no extra spaces or special characters

## What Gets Built

The successful build creates:
- `src/7kaa` - The main game executable (macOS ARM64 binary)
- Various object files and libraries in subdirectories

## Game Data

The game requires the data files from the `data/` directory to run properly. Make sure to run the game from the source directory with `SKDATA=data` environment variable set.

### Music Files

The game supports music files that should be placed in `data/MUSIC/` directory. The music files are:

- **WAR.WAV** - Main menu and battle music
- **WIN.WAV** - Victory music
- **LOSE.WAV** - Defeat music
- **Civilization themes** - CHINESE.WAV, GREEK.WAV, JAPANESE.WAV, MAYA.WAV, NORMAN.WAV, PERSIAN.WAV, VIKING.WAV

Music files must be in uppercase `.WAV` format and can be downloaded from https://7kfans.com/download/.

## About Seven Kingdoms: Ancient Adversaries

Seven Kingdoms: Ancient Adversaries is a real-time strategy game that was originally commercial but was released as open source. The game features complex diplomacy, trade, and military systems set in ancient times.

- **Official Website:** https://7kfans.com/
- **Source Code:** Available from the official website
- **License:** GPL (see COPYING file in source)

## Contributing

This build configuration was created to help macOS users (especially Apple Silicon Mac users) easily build and play Seven Kingdoms: Ancient Adversaries. If you encounter issues or have improvements, please feel free to contribute!