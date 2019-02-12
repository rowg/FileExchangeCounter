# FileExchangeCounter
Parses and summarizes SeaSonde FileExchange logs for easier monitoring of file transfers.

## Introduction
SeaSonde's FileExchange program fetches files from remote "radial" computers to a central "Combiner" computer. The log files generated by FileExchange contain lines showing the number of data files of each type that are transferred and the times of each transfer, but these log files are large and numerous and so are unsuitable for user monitoring of file transfer behaviour.

The Bash scripts contained in the FileExchangeCounter repository parse the FileExchange logs and "boil them down" into summaries of the number of files of each type transferred in a given day. 

The more compact log files thus created are in turn summarized in a Web-browser viewable table for easy monitoring (the compact log files would also be suitable for creating time-series plots of file-download volumes, but this has not been implemented).

## Motivation
An easy-to-read summary of a day's FileExchange file transfers can be useful for alerting the operator to instances in which fewer than the expected number of files have been transferred. Generally, though, the operator will notice when files are failing to show up. 

A more insidious problem occurs when an incorrect setting or configuration in SeaSonde's Archivalist causes "thrashing" behaviour:

1. FileExchange fetches files;

2. Archivalist immediately archives the files; 

3. FileExchange fetches the same files *again*, and so on.

Situations like these can degrade system performance and greatly increase the cost of data transfers if the remote computers are on cellular or satellite links. The operator is unlikely to notice, though, as there are no gaps in the incoming data to indicate a problem with the file transfers. Your first indication of a problem may be (as it was in my case) an email from Accounting asking why your cellular bill has suddenly doubled.

## The Output
The output from the FileExchangeCounter scripts is twofold. First, ASCII log files, one for each radial station/file type combination are generated. These contain lines of text, each containing a datestamp string and an integer indicating the number of files that were transferred on the corresponding day.

The second thing output by the FileExchangeCounter scripts is an html file. When viewed in a Web browser, it displays a table with one row for each radial station and a column for each data file type. See the image file *FileExchangeCounterScreenshot.png*, included in this repo, for an example.

---

![Screenshot of FileExchangeCounter html table](./FileExchangeCounterScreenshot.png?raw=true "Screenshot of FileExchangeCounter html table")

---

In a given day, you might expect 24 .ruv files, 24 .png files, approximately 144 CSS files, and approximately 338 RangeSeries files to be transferred from a particular radial station. With these numbers in mind, a look at the table in *FileExchangeCounterScreenshot.png* reveals three problems with Ocean Networks Canada's CODAR systems. 

First, station *VCOL* is falling behind, with only 18 CSS files and 15 .png files (in the "Figs" column) transferred rather than the expected 24 of each. This is not surprising, as *VCOL* is known to be experiencing communications problems.

Second, station *VGPT* is also falling behind. Again, this is not a surprise, though this time the culprit was a power outage at the site.

Third, all the stations (apart from *VGPT*, which was operating only part of the day) have transferred about *four times* as many Range Series files than expected. This turned out to be due to an incorrect setting in Archivalist, which has since been fixed. 

## Requirements
The scripts assume that the Combiner computer has FileExchange log files in the /Codar/SeaSonde/Logs/FileExchangeLogs/ directory, with names of the form *Site5_VGPT_Rads_ssh_2019-02.log* (with *VATK* being a station name, *Rads* a file type, and a *yyyy-mm* (year-month) datestring as the last element of the filename before the *.log* extension. If your files follow a different filenaming convention, you may need to modify the code slightly.

The scripts make use of an environment variable called "LOGPATH", which defines where the output is to go and which must be set before the scripts are run. Alternatively, modify the scripts to hard-code the output directory to the location of your choosing.

## Set up
Edit your *crontab* to have the following line (modify the value of LOGPATH and the path to the script as required):

    0  1 * * *    export LOGPATH=/Users/codar/myLogs/; /Users/codar/myScripts/daily_filexch_counter.sh > $LOGPATH/daily_filexch_counter.log 2>&1
    
*daily_filexch_counter.sh* will now run automatically at 01:00 a.m. every day and generate a file named *daily_filexch_counter_summary.html* in the directory given by LOGPATH. 

Open this html file in your browser once a week or so to monitor the behaviour of FileExchange at a glance.
