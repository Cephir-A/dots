#!/bin/bash
if [ -z `pgrep conky` ] 
then
  killall conky
fi
conky -c $HOME/.config/conky.conf &
