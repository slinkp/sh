#!/bin/bash

source ~/sh/pw_functions

INFILE=$1
shift
OUTFILE=$1

USAGE="Usage: $0 infile [outfile]\nCreates a mono mp3 version by mixing both channels"


if [ -z "$INFILE" ]; then
    die "$USAGE"
elif [ ! -f "$INFILE" ]; then
    shout "$USAGE"
    die "${INFILE} not found"
fi

if [ -z "$OUTFILE" ]; then
    OUTFILE="${INFILE%.*}_mono.mp3"
    echo "Set default outfile to $OUTFILE"
fi
TMPOUT=`mktemp --suffix=.wav`
safe mplayer -ao pcm:waveheader:file=${TMPOUT} -af pan=1:0.5:0.5 "$INFILE"
safe lame -m m -V 1 "$TMPOUT" "$OUTFILE"
echo "Wrote to $OUTFILE"
du -k "$INFILE" "$OUTFILE"
rm -f "$TMPOUT"

