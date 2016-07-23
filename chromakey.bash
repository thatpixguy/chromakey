#!/bin/bash
#Xephyr :1 -reset -terminate & while ! xprop -display :1 -root ; do false ; done ; xterm


BACKGROUND_RES="800x600"
KEY_RES="640x480"

# the larger of BACKGROUND_RES and KEY_RES
MIX_RES="800x600"

OUTPUT_RES="1024x768"
OFFSET="+0+0"

KEY_R=22
KEY_G=41
KEY_B=63
KEY_ANGLE=20

BACKGROUND_GEOMETRY="${BACKGROUND_RES}${OFFSET}"
KEY_GEOMETRY="${KEY_RES}${OFFSET}"

#BACKGROUND_COMMAND="gst-launch-0.10 v4l2src ! videoscale method=0 ! video/x-raw-yuv, width=640 ! ffmpegcolorspace ! ximagesink"
BACKGROUND_COMMAND="vlc -f --vout x11 $HOME/Downloads/2015-07-10_488202_512K-part.mp4"
#BACKGROUND_COMMAND="mplayer -fs $HOME/Downloads/2015-07-10_488202_512K-part.mp4"
#KEY_COMMAND="display -resize $KEY_RES -geometry $GEOMETRY colorwheel-rgb-640.png"
KEY_COMMAND="toonloop -f --width 1280 --height 720"

#XEPHYR_OPTS="-screen ${INPUT_RES} -noreset -ac -br -nocursor -dumb -noxv -nodri"
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
( DISPLAY=:1 $BACKGROUND_COMMAND ; kill $BACKGROUND_XEPHYR_PID ) &

Xephyr :2 -screen $KEY_RES $XEPHYR_OPTS &
KEY_XEPHYR_PID=$?
wait_for_display :2
( DISPLAY=:2 $KEY_COMMAND ; kill $KEY_XEPHYR_PID ) &

( 
  gst-launch-1.0 \
    videomixer name=mix background=black ! videoscale ! video/x-raw,width=${OUTPUT_RES%x*},height=${OUTPUT_RES#*x} ! videoconvert ! ximagesink sync=false \
    ximagesrc use-damage=0 display-name=:1 show-pointer=0 ! videoscale ! video/x-raw,width=${MIX_RES%x*},height=${MIX_RES#*x} ! mix. \
    ximagesrc use-damage=0 display-name=:2 show-pointer=0 ! alpha method=custom target-r=$KEY_R target-g=$KEY_G target-b=$KEY_B angle=$KEY_ANGLE ! videoscale ! video/x-raw,width=${MIX_RES%x*},height=${MIX_RES#*x} ! mix. \

  kill $KEY_XEPHYR_PID $BACKGROUND_XEPHYR_PID
) &

sleep 2 

echo "Press enter in this window to toggle fullscreen"
while read ; do 
  wmctrl -r "gst-launch-1.0" -b toggle,fullscreen
done

