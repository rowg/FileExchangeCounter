#!/bin/sh
#
# daily_filexch_counter.sh--To be called once a day by cron. Invokes 
# filexch_counter.sh to count the number of files that were transferred
# yesterday by FileExchange.
#
# Output is to log files, one for each FileExchange log found.
#
# Optional input argument dateStr (yyyy-mm-dd format) can be 
# specified (for backlog of log files, for example). Default
# behaviour is to use yesterday's date.
#
# Syntax: daily_filexch_counter.sh [dateStr]
#
# e.g.,   daily_filexch_counter.sh 2019-02-03
#
# Example of running over backlog of dates:
# startDate=$(date -j -f "%Y%m%d" 20190101 "+%Y%m%d");
# endDate=$(date -j -f "%Y%m%d" 20190208 "+%Y%m%d");
# currDate=$startDate
# while [ $currDate -le $endDate ]; do
#   dateStr=$(date -j -f "%Y%m%d" $currDate "+%Y-%m-%d");
#   echo $dateStr
#   daily_filexch_counter.sh $dateStr
#   currDate=$(date -v +1d -j -f "%Y%m%d" $currDate "+%Y%m%d");
# done
#
# 2019-02-09 20:03:44 GMT--kpb@uvic.ca
################################################################

################################################################
# REVISION HISTORY
#
# 2019-02-09, kpb--Created.
#
# 2019-02-10, kpb--Added html generation.
#
################################################################

echo $(date '+%Y-%m-%d %H:%M:%S'), $0--Starting. >&2

if [ $# -eq 0 ]; then
  # FileExchange log files contain lines that look like this:
  #  2019-02-06 06:40:14 GMT - 1 files transferred
  # So look for "yesterday" strings in that format.
  dayStr=$(date -v -1d '+%Y-%m-%d')
elif [ $# -eq 1 ]; then
  dayStr=$1
else
  echo $0--Incorrect number of input arguments. Aborting. >&2
  exit 1
fi

inDir=/Codar/SeaSonde/Logs/FileExchangeLogs
outDir=${LOGPATH}/FileExchangeCounter

if [ ! -e $outDir ]; then
  mkdir $outDir
fi

# Name of files to output to will incorporate the month (new one each month).
monthStr=$(echo $dayStr | awk -F - '{printf "%s%s", $1,$2}')

# ...n.b., look only in FileExchange log files for the month in question or
# will get false zeroes (e.g., zero files from May 5 in FileExchange log for July 1).
yearMonthStr=$(echo $dayStr | awk -F - '{printf "%s-%s", $1,$2}')

for inFile in ${inDir}/Site*${yearMonthStr}.log; do
  # ...Output file names will incorporate name of station and type of file fetched by
  # FileExchange. This information is contained in the FileExchange log file names,
  # e.g., Site5_VGPT_Rads_ssh_2019-02.log. So for each month, there will be one
  # output file for each station/file type combination found in the FileExchange 
  # log directory.
  b=$(basename $inFile)
  outName=$(echo $b | awk -F _ '{printf "%s/%s_%s_%s_%s.log", x,$1,$2,$3,y}' x=$outDir y=$monthStr)

  # Call filexch_counter.sh for this day and this FileExchange log file.
  numFiles=$(filexch_counter.sh $dayStr $inFile)

  # Append timestamped output to log file.
  echo $dayStr $numFiles >> $outName
  #echo $inFile $dayStr $numFiles
  
done

# Create html summary of this day's activity.
htmlFile=${outDir}/daily_filexch_counter_summary.html
filexch_counter_html.sh $dayStr > $htmlFile

echo $(date '+%Y-%m-%d %H:%M:%S'), $0--Finished. >&2
exit 0
