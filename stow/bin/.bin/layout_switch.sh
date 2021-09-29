#!/bin/env bash
if [[ -n "$1" ]]; then
	setxkbmap $1
else
	layout=$(setxkbmap -query | awk 'END{print $2}')
	case $layout in
		us)
			setxkbmap ca
			;;
		ca) 
			setxkbmap us
			;;
		*)
			setxkbmap us
			;;
	esac
fi

