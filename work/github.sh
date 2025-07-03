#!/bin/bash

milestone() {
  unixtime=$(date +%s)
  hour=$(date +%k)
  day=$(date +%w)

  # if it's after friday at noon, add enough days to be sure we count as in next week
  [[ $day = 5  && $hour -gt 12 || $day -gt 5 ]] && echo "inc" && ((unixtime=$unixtime + 3*24*60*60))

  year=$(date -d @"$unixtime" +%Y)
  # from: 
  # https://stackoverflow.com/questions/29931375/how-to-use-unix-date-function-to-calculate-quarter-of-the-year
  quarter=$(($(($((10#$(date -d @"$unixtime" +%m))) - 1)) / 3 + 1))
  week=$(expr $(date -d @"$unixtime" +%U) + 1)

  milestone="$year-Q$quarter-$week"
  echo "$milestone"
}

gh-list () {
  gh issue -a @me --search "milestone:$(milestone)" "$*" list
}

gh-list-team() {
 gh-list --label "team: $1"
}
