# active_queue_by_inj_date.pl #

## Usage ##
./active_queue_by_inj_date.pl [-d] [-log logfile]

## Purpose ##
This script will connect to the local Momentum instance and pull a list of all of the domains in the active queue with more than 100 messages in the queue.  Each of the messages for each of these domains will then be queried for the date of injection and summarized.  This process can take a very long time, as there are also some pauses built in to the script to help avoid overwhelming the system.  If you want to see how it's progressing you can use -d to see the progress.

Once this is complete, it will dump out a simple table showing the number of messages in the active queue grouped by injection date.  

## Sample Output ##
	/active_queue_sort.pl -debug
	Processing aol.com....................................................................................................Done
	Processing gmail.com....................................................................................................Done
	Processing live.com....................................................................................................Done
	Processing msn.com....................................................................................................Done
	Date            Count
	2012-08-22      112
	2012-08-23      88
	2012-08-24      300 

