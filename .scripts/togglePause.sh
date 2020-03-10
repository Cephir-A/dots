#!/bin/bash
function status {
  playerctl status
}
stat=$(status)
if [ $stat = "Playing" ]
then
  playerctl pause
else
  playerctl play
fi
