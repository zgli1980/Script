#!/bin/bash

echo "Y -- to start a new bath script"
echo "N -- to append to previous"

read

if [[ $REPLY == "Y" || "y" ]]; then
rm -rf convert.sh
fi

echo "Please add a file or input 'q' to exit"

read

while [ "$REPLY" != q ]; 
do

cat >>convert.sh<<EOF
ffmpeg -i "$REPLY" -acodec aac -ac 2 -strict experimental -ab 160k -vcodec libx264 -preset slow -profile:v baseline -level 30 -maxrate 10000000 -bufsize 10000000 -b 1200k -f mp4 -threads 0 "$REPLY".mp4
EOF
 
echo $REPLY " has been added"
echo "Please add another file or input 'q' to exit"

read

done

chmod +x convert.sh

echo "Do you want to start convertion now?"
read

if [[ $REPLY == "Y" || "y" ]]; then
convert.sh
else
echo "Please run ./convert.sh in terminal to start the convertion"
fi
