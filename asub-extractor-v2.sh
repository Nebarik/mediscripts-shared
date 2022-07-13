#!/bin/bash

# Usage: "asub-extractor.sh" within a folder of Anime MKVs. 
# Or specify folder eg "asub-extractor.sh Anime/Naruto"
# Requires mkvtoolnix

# Script will first check if there exists a SRT file already and will skip those episodes. - Can be run multiple times without going over past efforts
# If not then it will export the english subtitles into a SRT file and remove the default flag from the mkv. - Emby will now default to using the SRT file for the episode. 

#-------

# Folder and file finding
if [ "$1" = "" ]; then
  DIR="."
else
  DIR="$1"
fi

find "$DIR" -type f -name '*.mkv' | while read filename
do

subtitlename=${filename%.*}

# Colours!

RED='\033[1;31m'
YEL='\033[1;33m'
GRN='\033[0;32m'
ORN='\033[0;33m'
NC='\033[0m'

# Does sub already exist?
for f in ...
do
    if [[ -f "$subtitlename.eng.default.ass" ]] || [[ -f "$subtitlename.eng.default.sub" ]] || [[ -f "$subtitlename.en.srt" ]]
    then
    printf "${YEL}[Skipping (sub exists)]:${NC} $filename\n"
    elif [[ $(mkvmerge -i "$filename" | grep 'subtitles' | grep 'subtitles') = "" ]]
    then 
    printf "${ORN}[Skipping (no subs found)]:${NC} $filename\n"
    else
    
# Extract the subs
    mkvmerge -i "$filename" | grep 'subtitles' | while read subline
  do
    tracknumber=`echo $subline | egrep -o "[0-9]{1,2}"`
   `mkvextract tracks "$filename" $tracknumber:"$subtitlename.eng.default.ass"`
   cp "$subtitlename.eng.default.ass" "$subtitlename.en.srt" > /dev/null 2>&1
#    `mkvextract tracks "$filename" 2:"$subtitlename.en.srt" > /dev/null 2>&1`
    `chmod g+rw "$subtitlename.eng.default.ass" > /dev/null 2>&1`
    `chmod g+rw "$subtitlename.en.srt" > /dev/null 2>&1`
    `chmod g+rw "$subtitlename.eng.default.sub" > /dev/null 2>&1`
  done
  

 
# Remove default flag
    if [[ ! $(mkvmerge -J "$filename" | grep '"default_track": true') = "" ]]
    then
    mkvpropedit "$filename" --edit track:s1 --set flag-default=0 > /dev/null 2>&1
    else
    echo "[Already Not Default]: $filename"
    fi
printf "${GRN}[Completed]:${NC} $filename\n"
        fi
done
done

