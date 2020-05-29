killall -q polybar

while pgrep -u $UID -x polybar >/ddev/null; do sleep 1; done

if type "xrandr"; then
  PRIMARY=$(xrandr --query | grep " connected" | grep "primary" | cut -d" " -f1)
  MONITOR=$PRIMARY polybar --reload top &
  sleep 1
  for m in $(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1); do
    MONITOR=$m polybar --reload top &
  done
else
  polybar --reload top &  
fi 

#if type "xrandr"; then
#  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#    MONITOR=$m polybar bottom &
#  done
#else
#  polybar --reload bottom &  
#fi 
