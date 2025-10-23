#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: `basename $0` <input file>"
  exit 1
fi

INFILE="$1"
shift

# Known edge cases:
# Free - "All Right Now" splits successfully
# with noise=-49db:d=0.11
# but splits the intro up into chunks with anything less than that
# eg -49db:d=0.10 OR -48db:d=0.11.

ffmpeg -i "$INFILE" -af silencedetect=noise=-49dB:d=0.11 -f null - 2> raw.txt
grep "silence[start|end]" raw.txt > silence.txt

starts=(0)
while read -r line; do
  if [[ $line =~ silence_end:[[:space:]]([0-9.]+) ]]; then
    starts+=("${BASH_REMATCH[1]}")
  elif [[ $line =~ silence_start:[[:space:]]([0-9.]+) ]]; then
    ends+=("${BASH_REMATCH[1]}")
  fi
done < silence.txt

duration=$(ffprobe -i "$INFILE" -show_entries format=duration -v quiet -of csv="p=0")
ends+=($duration)

for i in "${!starts[@]}"; do
  duration=$(printf "%.6f" $(echo "${ends[$i]} - ${starts[$i]}" | bc))
  echo ffmpeg -i "$INFILE" -ss "${starts[$i]}" -t "$duration" -acodec libmp3lame "song_$((i+1)).mp3"
  ffmpeg -i "$INFILE" -ss "${starts[$i]}" -t "$duration" -acodec libmp3lame -aq 2 "song_$((i+1)).mp3"
done
