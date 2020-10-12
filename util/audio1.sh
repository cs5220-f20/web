#!/bin/sh

# Take the downloaded audio and upload it to the class directory.

scp ~/Downloads/audio.zip cslinux:/courses/cs5220/2020fa/lec/
ssh cslinux "mkdir -p /courses/cs5220/2020fa/lec/$1 && cd /courses/cs5220/2020fa/lec/$1 && unzip ../audio.zip && rm ../audio.zip"
mv ~/Downloads/audio.zip ~/Downloads/$1.zip
