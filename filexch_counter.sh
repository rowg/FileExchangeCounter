#!/bin/sh
#
# filexch_counter.sh--Counts the number of files pulled by filexch_ssh.pl
# for a specified day.
#
# The date string format yyyy-mm-dd (e.g., "2019-02-06") has been
# chosen to match that used by filexch_ssh.pl.
#
# Output is to stdout. Progress and error messages to stderr.
#
# Syntax: filexch_counter.sh dateStr filexch_log_file
#
# e.g.,   filexch_counter.sh 2019-02-06 /Codar/SeaSonde/Logs/FileExchangeLogs/Site5_VGPT_Rads_ssh_2019-02.log
#
# 2019-02-09 20:03:44 GMT--kpb@uvic.ca
################################################################

################################################################
# REVISION HISTORY
#
# 2019-02-09, kpb--Created.
#
################################################################

echo $(date '+%Y-%m-%d %H:%M:%S'), $0--Starting. >&2

if [ $# -ne 2 ]; then
  echo $0--Incorrect number of input arguments. Aborting. >&2
  exit 1
fi

dateStr=$1
filexch_log_file=$2

# FileExchange log files contain lines that look like this:
#  2019-02-06 06:40:14 GMT - 1 files transferred
# Look for lines corresponding to the specified date and add up the number of files transferred.
# grep ${dateStr} ${filexch_log_file} | grep "files transferred" | awk '{print $5}'
numFiles=$(grep ${dateStr} ${filexch_log_file} | grep "files transferred" | awk '{s+=$5}{printf"%d\n",s}' | tail -n 1)

# Output results to stdout.
if [ ${#numFiles} -eq 0 ]; then
  echo 0
else
  echo $numFiles
fi

echo $(date '+%Y-%m-%d %H:%M:%S'), $0--Finished. >&2
exit 0
