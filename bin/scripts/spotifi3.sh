if pgrep spotify > /dev/null; then
	spotify=""
	if sp status | grep 'Paused' > /dev/null; then
		spotify="$spotify     "
	else
		spotify="$spotify   "
	fi
	spotify=${spotify}$(sp current-oneline)	
	echo $spotify
fi
