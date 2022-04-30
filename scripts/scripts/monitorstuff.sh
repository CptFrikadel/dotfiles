#! /bin/bash

options="LVDS
LVDS+VGA"

menu=$(echo -e "LVDS\nLVDS+VGA left\nLVDS+VGA mirror" | rofi -dmenu -p "Monitor Config:")


LVDS() {
	xrandr --output LVDS --primary --auto --output DisplayPort-0 --off --output DisplayPort-1 --off --output DisplayPort-2 --off --output VGA-0 --off
}

LVDS_VGA_left() {
	xrandr --output LVDS --auto --output DisplayPort-0 --off --output DisplayPort-1 --off --output DisplayPort-2 --off --output VGA-0 --primary --auto --left-of LVDS
}

LVDS_VGA_mirror() {
	xrandr --output LVDS --primary --auto --output DisplayPort-0 --off --output DisplayPort-1 --off --output DisplayPort-2 --off --output VGA-0 --mode 1600x900 --same-as LVDS
}

case ${menu} in 	
	"LVDS") LVDS;;
	"LVDS+VGA left") LVDS_VGA_left;;
	"LVDS+VGA mirror") LVDS_VGA_mirror;;
esac
