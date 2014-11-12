#!/bin/bash

# replaces empty spaces with underscores
rename 's/\ /_/' *
 
# fix shitty images 
for img in `ls *.png`
do
  convert $img \
  -colorspace RGB +sigmoidal-contrast 11.6933 \
  -define filter:filter=Sinc -define filter:window=Jinc -define filter:lobes=3 \
  -sigmoidal-contrast 11.6933 -colorspace sRGB \
  -background white -alpha Background fixed/$img
done
 
 
