#!/bin/zsh

milestone() {
  unixtime=$(strftime %s)
  hour=$(strftime %k $unixtime)
  day=$(strftime %w $unixtime)
  [ $day = 5 ] && [ $hour > 12 ] && unixtime=($unixtime - 24*60*60)
  year=$(strftime %Y $unixtime)
  # from: 
  # https://stackoverflow.com/questions/29931375/how-to-use-unix-date-function-to-calculate-quarter-of-the-year
  quarter=$(($(($((10#$(strftime %m $unixtime))) - 1)) / 3 + 1))
  week=$(expr $(strftime %V $unixtime) + 1)
  milestone="$year-Q$quarter-$week"
  echo $milestone
}
