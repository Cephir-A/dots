echo "feh --bg-fill $HOME/Pictures/wallpapers/$(ls $HOME/Pictures/wallpapers | rofi -dmenu)" > $HOME/.scripts/wallpaper.sh
sh $HOME/.scripts/wallpaper.sh
