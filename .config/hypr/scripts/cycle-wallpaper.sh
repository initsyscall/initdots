#!/usr/bin/env bash

dir="$HOME/Pictures/wallpaper"
mapfile -t wallpapers < <(find "$dir" -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.png' -o -name '*.jpeg' -o -name '*.gif' \) | sort)

if [[ ${#wallpapers[@]} -eq 0 ]]; then
	notify-send "Wallpaper" "No wallpapers found in $dir"
	exit 1
fi

current=$(awww query 2>/dev/null | grep -oP 'image: \K.*')

for i in "${!wallpapers[@]}"; do
	if [[ "${wallpapers[$i]}" == "$current" ]]; then
		next=$(( (i + 1) % ${#wallpapers[@]} ))
		awww img "${wallpapers[$next]}"
		sed -i "s|path = .*|path = ${wallpapers[$next]}|" "$HOME/.config/hypr/hyprlock.conf"
		notify-send "Wallpaper" "$(basename "${wallpapers[$next]}")"
		exit 0
	fi
done

awww img "${wallpapers[0]}"
sed -i "s|path = .*|path = ${wallpapers[0]}|" "$HOME/.config/hypr/hyprlock.conf"
notify-send "Wallpaper" "$(basename "${wallpapers[0]}")"
