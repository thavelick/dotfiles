#!/bin/zsh

milestone() {
  unixtime=$(strftime %s)
  hour=$(strftime %k $unixtime)
  day=$(strftime %w $unixtime)

  # if it's after friday at noon, add enough days to be sure we count as in next week
  [[ $day = 5  && $hour -gt 12 || $day -gt 5 ]] && echo "inc" && ((unixtime=$unixtime + 3*24*60*60))

  year=$(strftime %Y $unixtime)
  # from: 
  # https://stackoverflow.com/questions/29931375/how-to-use-unix-date-function-to-calculate-quarter-of-the-year
  quarter=$(($(($((10#$(strftime %m $unixtime))) - 1)) / 3 + 1))
  week=$(expr $(strftime %U $unixtime) + 1)

  milestone="$year-Q$quarter-$week"
  echo $milestone
}

gh-list () {
  gh issue -a thavelick --search "milestone:$(milestone)" $* list
}

gh-list-team() {
 gh-list --label "team: $1"
}
