WSTATUS(1) "github.com/paulchambaz/wstatus" "General Commands Manual"

# NAME

*wstatus* - Status bar text generator

# SYNOPSIS

*wstatus* [*-r*]

# DESCRIPTION

*wstatus* runs shell commands at specified intervals and outputs their results
in a single line. It is designed for window managers like *dwl* that read status
text from stdin.

Each command runs at its configured interval. All outputs are concatenated with
" | " as a separator. Commands are executed through */bin/sh*, allowing pipes,
redirections, and command substitutions.

# OPTIONS

*-r*
	Refresh all commands immediately by sending SIGUSR1 to the running
	instance

# CONFIGURATION

*wstatus* reads its configuration from *~/.config/wstatus.cfg*. Each line
contains two fields separated by a comma: an interval in milliseconds and a
shell command.

```
1000,date +%H:%M:%S
2000,pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}'
5000,cat /sys/class/power_supply/BAT0/capacity
```

The interval determines how often the command executes. Commands can include
pipes, redirections, variable expansions, and other shell features.

# USAGE

To use *wstatus* with a window manager:

```
wstatus | dwl
```

To refresh all commands:

```
wstatus -r
```

This sends a SIGUSR1 signal to the running instance, causing all commands to
execute immediately.

# EXAMPLES

A typical configuration:

```
1000,date +"%a %d %b %H:%M"
2000,amixer get Master | grep -o "[0-9]*%" | head -1
5000,sensors | grep "Package id 0" | awk '{print $4}'
10000,free -h | awk '/^Mem:/ {print $3 "/" $2}'
```

This displays date, volume, CPU temperature, and memory usage at different
intervals.

# AUTHORS

This program was written by Paul Chambaz in 2024. It is licensed under the
GPLv3, for more information, please read the *LICENSE* file.
