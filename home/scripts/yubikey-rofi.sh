#!/usr/bin/env bash

account=$(ykman oath accounts list | rofi -dmenu -e 'Select your Account')
ykman oath accounts code -s "$account" | tr -d '\n' | copyq copy -
notify-send "Copied to clipboard." --icon=dialog-information
