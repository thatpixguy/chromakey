#!/bin/bash


BACKGROUND_RES="800x600"
KEY_RES="640x480"


OUTPUT_RES="1024x768"
OFFSET="+0+0"

KEY_R=0
KEY_G=255
KEY_B=0
KEY_ANGLE=20

# the larger of BACKGROUND_RES and KEY_RES
MIX_RES=$((${BACKGROUND_RES%x*}>${KEY_RES%x*}?${BACKGROUND_RES%x*}:${KEY_RES%x*}))x$((${BACKGROUND_RES#*x}>${KEY_RES#*x}?${BACKGROUND_RES#*x}:${KEY_RES#*x}))

BACKGROUND_GEOMETRY="${BACKGROUND_RES}${OFFSET}"
KEY_GEOMETRY="${KEY_RES}${OFFSET}"

BACKGROUND_COMMAND="vlc --no-audio -f --vout x11"

KEY_COMMAND="toonloop -f"

XEPHYR_OPTS="-noreset -ac -br -nocursor -dumb -noxv -nodri"

function wait_for_display {
 echo -n "Waiting for display $1"
 while ! xprop -display $1 -root >& /dev/null ; do echo -n "." ; done
 echo
}

Xephyr :1 -screen $BACKGROUND_RES $XEPHYR_OPTS &
BACKGROUND_XEPHYR_PID=$?
wait_for_display :1
DISPLAY=:1 metacity &
( DISPLAY=:1 $BACKGROUND_COMMAND ; echo Background died. ; kill $BACKGROUND_XEPHYR_PID ) &

Xephyr :2 -screen $KEY_RES $XEPHYR_OPTS &
KEY_XEPHYR_PID=$?
wait_for_display :2
( DISPLAY=:2 $KEY_COMMAND ; echo Key died. ; kill $KEY_XEPHYR_PID ) &



( 
  gst-launch-1.0 \
    videomixer name=mix background=black sink_1::zorder=1 sink_2::zorder=2 ! videoconvert ! video/x-raw,width=${MIX_RES%x*},height=${MIX_RES#*x} ! videoscale ! video/x-raw,width=${OUTPUT_RES%x*},height=${OUTPUT_RES#*x} ! ximagesink sync=false \
    ximagesrc use-damage=0 display-name=:2 show-pointer=0 ! alpha method=custom target-r=$KEY_R target-g=$KEY_G target-b=$KEY_B angle=$KEY_ANGLE ! videoscale ! video/x-raw,width=${MIX_RES%x*},height=${MIX_RES#*x} ! mix.sink_2 \
    ximagesrc use-damage=0 display-name=:1 show-pointer=0 ! videoscale ! video/x-raw,width=${MIX_RES%x*},height=${MIX_RES#*x} ! mix.sink_1 \

  kill $KEY_XEPHYR_PID $BACKGROUND_XEPHYR_PID
) &

sleep 2 

echo "Press enter in this window to toggle fullscreen"
while read ; do 
  wmctrl -r "gst-launch-1.0" -b toggle,fullscreen
done

