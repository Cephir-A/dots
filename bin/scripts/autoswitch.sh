export DISPLAY=:0.0


#if error
set -e

HDMI_STATUS = $(</sys/class/drm/card1/card1-HDMI-A-1/status

if [ "connected" == "$HDMI_STATUS" ]; then
	xrandr --output HDMI-1-2 --off --output eDP-1-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1-1 --mode 1920x1080 --pos 3840x0 --rotate normal --output DP-1-1 --off --output DP-1-2 --off
	/usr/bin/notify-send --urgency=low -t 5000 "Graphics Update" "HDMI Plugged In"
else
	xrandr --output HDMI-1-2 --off --output eDP-1-1 --primary --mode 3840x2160 --pos 0x0 --rotate normal --output HDMI-1-1 --off --output DP-1-1 --off --output DP-1-2 --off
	/user/bin/notify-send --urgency=low -t 5000 "Graphics Update" "HDMI Unplugged"
	exit
fi

killall plank
plank &
sudo /etc/init.d/gdm restart
