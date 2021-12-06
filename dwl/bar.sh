#!/bin/sh

set -e
echo 'aaa| 1!| 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 |'
echo "begin--: $1" >> /tmp/bar.log
fname="/tmp/dwltags-WL-1";
while true
do
    #make sure the file exists
    while [ ! -p $fname ]
    do
        inotifywait -qqe create `dirname $fname`
    done;
    #wait for dwl to close it after writing
    # inotifywait -qqe close_write $fname
    sleep 1
    echo "+++++++" >> /tmp/bar.log
    titleline="0"
    tagline=$((titleline+1))

    title=`sed "$titleline!d" $fname`
    taginfo=`sed "$tagline!d" $fname`

    isactive=`echo "$taginfo" | cut -d ' ' -f 1`

    ctags=`echo "$taginfo" | cut -d ' ' -f 2`

    mtags=`echo "$taginfo" | cut -d ' ' -f 3`

    layout=`echo "$taginfo" | cut -d ' ' -f 4-`

    echo "titleline: $titleline" >> /tmp/bar.log
    echo "tagline: $tagline" >> /tmp/bar.log
    echo "title: $title" >> /tmp/bar.log
    echo "taginfo: $taginfo" >> /tmp/bar.log

    for i in {0..8};
    do

        mask=$((1<<i))
        if (( "$ctags" & $mask ));
        then
            n="*$((i+1))"
        else
            n=" $((i+1))"
        fi
        if (( "$mtags" & $mask ));
        then
            echo -n "|$n!"
        else
            echo -n "|$n "
        fi
    done
    echo "| $layout $title"


done
