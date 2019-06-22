#!bin/fish
slurp | grim -g -$HOME/Pictures/screenshots/(date +'screenshot_%Y-%m-%d-%H%M%S.png')
