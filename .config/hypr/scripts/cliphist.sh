#!/bin/bash
# cliphist wrapper with rofi picker
cliphist list | rofi -dmenu -p "Clipboard" -theme ~/.config/rofi/cliphist.rasi | cliphist decode | wl-copy
