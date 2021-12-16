#!/bin/bash

youtube-dl -x --audio-format mp3 -o '%(autonumber)s %(title)s.%(ext)s' $@
