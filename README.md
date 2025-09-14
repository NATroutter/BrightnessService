<div align="center">
<h1 style="margin: 0px;font-weight: 700;font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Helvetica,Arial,sans-serif,Apple Color Emoji,Segoe UI Emoji">BrightnessService</h1>

![licence](https://img.shields.io/badge/License-MIT-brightgreen)

</div>

**BrightnessService** is a script that automatically dims your Raspberry Pi official 7" Touchscreen (v1.1) after a period of inactivity and restores full brightness when the user interacts with it. It can also be installed as a **systemd service** to run automatically in the background.

---

## Table of Contents

1. [Features](#features)
2. [Requirements](#requirements)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Configuration](#configuration)
6. [Debug Mode](#debug-mode)
7. [Safety Notes](#safety-notes)

---

## Features

- Automatically dims the screen after inactivity.
- Restores full brightness when the user interacts with the mouse.
- Runs as a **systemd service**.
- Configurable brightness levels and inactivity timeout.
- Supports manual ``start``, ``stop``, and ``status`` checking.

---

## Requirements

- Linux system with **systemd**.
- **xdotool** installed for mouse/touch tracking:
  ```bash
  sudo apt install xdotool
- Access to ``/sys/class/backlight/.../brightness`` for your display.
- Bash shell.

## Installation
1. Goto your home directory ``cd /home/pi``
2. Install xdotool for mouse/touch tracking
   ```bash
   sudo apt install xdotool
3. Run this command to download and install the latest version of the BrightnessService.
   ``` bash
   wget -qO- https://raw.githubusercontent.com/NATroutter/BrightnessService/main/brightness.sh
4. Make script executable with this command.
   ``` bash
   chmod +x brightness.sh
5. Open the script and update the configuration variables at the top of the script.
   ``` bash
   sudo nano brightness.sh
6. Done.

## Usage
Run the script with one of the following arguments:
- **./brightness.sh start**         - *Start the systemd service*
- **./brightness.sh stop**          - *Stop the service*
- **./brightness.sh restart**       - *Restart the service*
- **./brightness.sh status**        - *Check the status of the service*
- **./brightness.sh run**           - *Run the script manually (foreground)*
- **./brightness.sh restore**       - *Restore full brightness immediately*
- **./brightness.sh install**       - *Install as a systemd service*

## Configuration
Open the script ``brightness.sh`` using your favourite text editor at the top of the script there are configs.
| Variable     | Description     |
| --- | --- |
| ``BRIGHTNESS_PATH`` | Path to your display brightness file.    |
| ``DESKTOP_USER``    | The user who owns the X session.         |
| ``FULL_BRIGHTNESS`` | Brightness value when active.            |
| ``DIM_BRIGHTNESS``  | Brightness value when idle.              |
| ``INACTIVITY_TIME`` | Time in seconds to wait before dimming.  |
| ``DEBUG``           | Set to 1 to print debug messages.        |

## Debug Mode
Set ``DEBUG=1`` at the top of the script to print detailed logs about mouse activity, brightness changes, and service actions.

## Safety Notes
- The script modifies ``/sys/class/backlight/.../brightness``, which may require sudo privileges.
- Always test the script with ``./brightness.sh`` run before installing as a service.
- Stop the service before making changes to the script:
   ``` bash
   sudo systemctl stop brightness.service
- Incorrect configuration of ``BRIGHTNESS_PATH`` or user permissions may prevent the script from working.