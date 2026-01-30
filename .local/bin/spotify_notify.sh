#!/bin/bash

# Extract song title and artist
playerctl --player=spotify metadata --format "Now Playing: {{title}} by {{artist}}" --follow | while read -r message; do
  notify-send -i spotify "Spotify" "$message"
done
