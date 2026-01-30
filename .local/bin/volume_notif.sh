#!/bin/bash

volume_step=1
max_volume=100
notification_timeout=2000
download_album_art=true
show_album_art=true
show_music_in_volume_indicator=true

default_volume_icon="/usr/share/icons/breeze-dark/actions/24/player-volume.svg"

function get_volume {
  pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]{1,3}(?=%)' | head -1
}

function get_mute {
  pactl get-sink-mute @DEFAULT_SINK@ | grep -Po '(?<=Mute: )(yes|no)'
}

function get_volume_icon {
  volume=$(get_volume)
  mute=$(get_mute)
  if [ "$volume" -eq 0 ] || [ "$mute" == "yes" ]; then
    volume_icon="󰝟 "
  elif [ "$volume" -lt 50 ]; then
    volume_icon="  "
  else
    volume_icon="  "
  fi
}

function get_active_player {
  local playing_player=$(playerctl -l 2>/dev/null | while read -r p; do
    if [[ "$(playerctl -p "$p" status 2>/dev/null)" == "Playing" ]]; then
      echo "$p"
      break
    fi
  done)

  if [ -n "$playing_player" ]; then
    echo "$playing_player"
  else
    playerctl -l 2>/dev/null | head -n 1
  fi
}

function get_album_art {
  player=$(get_active_player)
  [ -z "$player" ] && album_art="$default_volume_icon" && return

  url=$(playerctl -p "$player" metadata --format "{{mpris:artUrl}}" 2>/dev/null)

  if [[ $url == "file://"* ]]; then
    album_art="${url/file:\/\//}"
  elif [[ $url == http* ]] && [[ $download_album_art == "true" ]]; then
    filename="$(echo "$url" | sha256sum | cut -d' ' -f1)"
    if [ ! -f "/tmp/$filename" ]; then
      wget -q -O "/tmp/$filename" "$url"
    fi
    album_art="/tmp/$filename"
  else
    album_art="$default_volume_icon"
  fi
}

function show_volume_notif {
  volume=$(get_volume)
  get_volume_icon
  player=$(get_active_player)

  if [[ $show_music_in_volume_indicator == "true" && -n "$player" ]]; then
    local title=$(playerctl -p "$player" metadata title 2>/dev/null)
    local artist=$(playerctl -p "$player" metadata artist 2>/dev/null)

    if [ -n "$title" ] && [ -n "$artist" ]; then
      current_song="$title - $artist"
    elif [ -n "$title" ]; then
      current_song="$title"
    else
      current_song="Playing on ${player%%.*}"
    fi

    [[ $show_album_art == "true" ]] && get_album_art

    [ -z "$album_art" ] && album_art="$default_volume_icon"

    notify-send -e -t $notification_timeout \
      -a "SwayNC_Volume" \
      -h string:x-canonical-private-synchronous:volume_notif \
      -h int:value:$volume \
      -i "$album_art" \
      "$volume_icon $volume%" "$current_song"
  else
    notify-send -e -t $notification_timeout \
      -a "SwayNC_Volume" \
      -h string:x-canonical-private-synchronous:volume_notif \
      -h int:value:$volume \
      -i "$default_volume_icon" \
      "$volume_icon $volume%" "System Volume"
  fi
}

function show_music_notif {
  player=$(get_active_player)
  [ -z "$player" ] && return

  song_title=$(playerctl -p "$player" metadata --format "{{title}}" 2>/dev/null)
  song_artist=$(playerctl -p "$player" metadata --format "{{artist}}" 2>/dev/null)

  [[ $show_album_art == "true" ]] && get_album_art
  [ -z "$album_art" ] && album_art="$default_volume_icon"

  notify-send -e -t $notification_timeout \
    -a "SwayNC_Music" \
    -h string:x-canonical-private-synchronous:music_notif \
    -i "$album_art" \
    "$song_title" "$song_artist"
}

case $1 in
volume_up)
  pactl set-sink-mute @DEFAULT_SINK@ 0
  volume=$(get_volume)
  if [ $(("$volume" + "$volume_step")) -gt $max_volume ]; then
    pactl set-sink-volume @DEFAULT_SINK@ $max_volume%
  else
    pactl set-sink-volume @DEFAULT_SINK@ +$volume_step%
  fi
  show_volume_notif
  ;;
volume_down)
  pactl set-sink-volume @DEFAULT_SINK@ -$volume_step%
  show_volume_notif
  ;;
volume_mute)
  pactl set-sink-mute @DEFAULT_SINK@ toggle
  show_volume_notif
  ;;
next_track)
  playerctl next && sleep 0.2 && show_music_notif
  ;;
prev_track)
  playerctl previous && sleep 0.2 && show_music_notif
  ;;
play_pause)
  playerctl play-pause && show_music_notif
  ;;
daemon)
  playerctl metadata --format '{{title}}' --follow | while read -r line; do
    show_music_notif
  done
  ;;
esac
