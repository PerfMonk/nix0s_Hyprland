#!/bin/sh
wksp=$(hyprctl activewindow|grep workspace|awk '{print $2;}')
echo -e "{\"name\":\""$wksp"\"}"
exit
