echo "feh --bg-fill $HOME/Pictures/wallpapers/$(ls $HOME/Pictures/wallpapers | rofi -dmenu -theme $HOME/.config/rofi/launchers/kde_krunner.rasi)" > $HOME/.scripts/wallpaper.sh
sh $HOME/.scripts/wallpaper.sh
