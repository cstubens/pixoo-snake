# Pixoo Snake

A Snake game for the Pixoo 64 LED display, controlled via Android app. Written using Cursor.

## Game Description

Snake is a classic arcade game where you control a snake that grows longer as it eats food. The goal is to eat as much food as possible without colliding with yourself.

<table>
<tr>
<td valign="top"><img src="docs/emulator_screenshot.png" alt="Game Running in Emulator" width="300"/></td>
<td valign="top"><img src="docs/pixoo64.png" alt="Pixoo 64 LED Display" width="400"/></td>
</tr>
</table>

## Development Setup on MacOS

```bash
# Clone
git clone git@github.com:cstubens/pixoo-snake.git
cd pixoo-snake

# Install dependencies: Java, Android Studio, Android SDK, set env variables, etc.
# MacOS only. Has NOT been tested with a fresh machine since it was written.
# I wouldnt be suprised if this breaks -__-'
./setup.sh
```

After setup completes:
- Open Android Studio and complete the initial setup, following instructions from `setup.sh`.
- Run the app with `./run_in_emulator.sh`

## Emulator Management

The following scripts help manage the Android emulator:

- **Start**: `./start_emulator.sh` - Starts the emulator in the background
- **Stop**: `./stop_emulator.sh` - Stops the running emulator
- **Reset**: `./reset_emulator.sh` - Performs a soft reset of the emulator

## Building

Build an APK:
```bash
./build_apk.sh
```

## Debugging

View logs from the emulator:
```bash
# Show all logs
./tail_logs.sh

# Show only Pixoo-related logs
./tail_logs.sh -p

# Show only game-related logs
./tail_logs.sh -g

# Clear log buffer before showing logs
./tail_logs.sh -c
```

## TODOs

- The JAVA_HOME env variable is hardcoded in the scripts, which isnt very portable.
- The app crashes if the Pixoo device cant be found on local wifi.
