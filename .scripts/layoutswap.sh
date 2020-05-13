if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
  else
    killall compton
    zsh $1 #$1 will be the path to the layout script in question.
    compton &
    zsh $HOME/.scripts/wallpaper.sh 
    zsh $HOME/.scripts/local/monitors.sh
    zsh $HOME/.scripts/polybar_start.sh
fi
