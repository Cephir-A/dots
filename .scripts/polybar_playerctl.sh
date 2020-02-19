pctl=$(playerctl status | grep "No players found")
npf="No players found"
if [ "$pctl" != "$npf" ]; then
	spotify=""
	if playerctl status | grep 'Paused' > /dev/null; then
		spotify="$spotify      "
	else
		spotify="$spotify      "
	fi
	spotify=${spotify}$(playerctl metadata title)	
	echo $spotify
fi
