#!/bin/sh
#
# filexch_counter_html.sh--Outputs html code summarizing 
# FileExchange activity for specified day.
#
# Output is to stdout.
#
# Syntax: filexch_counter_html.sh dayStr
#
# e.g.,   filexch_counter_html.sh 2019-02-08
#
# 2019-02-09 20:03:44 GMT--kpb@uvic.ca
################################################################

################################################################
# REVISION HISTORY
#
# 2019-02-09, kpb--Created.
#
# 2019-03-04, kpb--Bugfix. Replaced use of rs with sed.
#
################################################################

echo $(date '+%Y-%m-%d %H:%M:%S'), $0--Starting. >&2

if [ $# -ne 1 ]; then
  echo $0--Incorrect number of input arguments. Aborting. >&2
  exit 1
fi

dayStr=$1

inDir=${LOGPATH}/FileExchangeCounter
outDir=$inDir

if [ ! -e $outDir ]; then
  mkdir $outDir
fi

# The yearMonth string (e.g., "201902") embedded in the filenames of the 
# FileExchangeCounter log files (e.g., "Site5_VGPT_Rads_201902.log").
yearMonthStr=$(echo $dayStr | awk -F - '{printf "%s%s", $1,$2}')

# Get list of all station names and file types referenced in all FileExchangeCounter log files.
stationNames=""
fileTypes=""
for f in ${inDir}/Site*.log; do
  b=$(basename $f)
  thisStation=$(echo $b | awk -F _ '{print $2}')
  thisType=$(echo $b | awk -F _ '{print $3}')
  stationNames=$(echo ${stationNames} $thisStation)
  fileTypes=$(echo ${fileTypes} $thisType)
done

# 2019-03-04, kpb--Workaround for bug in rs that garbles output if input is
# larger than 1024 characters. Use "sed" instead.
#fileTypes=$(echo $fileTypes | rs -T | sort -u)
#stationNames=$(echo $stationNames | rs -T | sort -u)
fileTypes=$(echo $fileTypes | sed -e $'s/ /\\\n/g' | sort -u)
stationNames=$(echo $stationNames | sed -e $'s/ /\\\n/g' | sort -u)

echo "<html>"
echo "<head>"
echo "<!--Prevent browser looking for favicon.ico (failing in Chrome, 2018-06-18)-->"
echo "  <link rel="icon" href="data:,">"
echo "</head>"
echo "<body>"
echo "<h1>FileExchangeCounter Summary for ${dayStr}</h1>"
echo "<table border=\"1\" cellpadding=\"10\">"

# Output header row. Columns are file types.
echo "<tr>"
echo "<td>stationName</td>"
for fileType in $fileTypes; do
  echo "<td>${fileType}</td>"  
done
echo "</tr>"

# Outer loop will be over station names. 
for stationName in $stationNames; do
  echo "<tr>"
  echo "<td>${stationName}</td>"

  # Inner loop over file types.
  for fileType in $fileTypes; do
     
     logFile=$(find $inDir -name Site\*_${stationName}_${fileType}_${yearMonthStr}.log -maxdepth 1)
     #echo $stationName $fileType ${#logFile} $logFile

     if [ ${#logFile} -eq 0 ]; then
       # No log file found for this station name/fileType/month combination.
       outStr="-"
     else
       tline=$(grep $dayStr $logFile)
       if [ ${#tline} -eq 0 ]; then
         # Log file found, but no entry for this day.
         outStr="0"
       else
         outStr=$(echo ${tline} | awk '{print $2}')
       fi
     fi

     echo "<td>${outStr}</td>"
  done

  echo "</tr>"
done

echo "</table>"
echo "</body>"
echo "</html>"

echo $(date '+%Y-%m-%d %H:%M:%S'), $0--Finished. >&2
exit 0
