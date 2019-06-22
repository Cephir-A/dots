if [ setxkbmap -query | grep layout = "gb,us" ] ;
then
	setxkbmap -layout us,gb
else
	setxkbmap -layout gb,us
fi
