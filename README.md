
This should be everything you need to install on a bare Ubuntu Trusty system

$ sudo apt-get install toonloop xserver-xephyr vlc wmctrl gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good graphicsmagick

Before running, you will need to edit the file and change the file that vlc is playing in "BACKGROUND_COMMAND".
It's currently pointing at some random video I had in my downloads directory ;)

You can change the RGB value that it is chromakeying by changing the KEY_R,G and B values. 
It's currently set to the colour of a t-shirt I was wearing when I was testing it ;)

Then run it with:

$ bash chromakey.bash

pix


