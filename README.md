# wstatus

Status bar text generator for window managers.

## Description

wstatus runs shell commands at specified intervals and outputs their results in a single line. It is designed for window managers like dwl that read status text from stdin. Written following the suckless philosophy, the entire program is under 150 lines of C code.

Commands are executed through /bin/sh, allowing pipes, redirections, and command substitutions. All outputs are concatenated with " | " as a separator.

## Installation
```sh
make
sudo make install
```

Or with Nix:
```sh
nix build
```

## Configuration

Create `~/.config/wstatus.cfg` with commands and their intervals in milliseconds:
```
1000,date +"%a %d %b %H:%M"
2000,amixer get Master | grep -o "[0-9]*%" | head -1
5000,cat /sys/class/power_supply/BAT0/capacity
```

## Usage

Pipe output to your window manager:
```sh
wstatus | dwl
```

Refresh all commands immediately:
```sh
wstatus -r
```

## License

GPLv3 - see LICENSE file.
