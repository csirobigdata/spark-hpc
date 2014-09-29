
This is a simple example demonstrating how to run spark applications with sparkhpc-submit.
It uses a basic WordCount application which source code is available in 'src' dir.
The prebuild application jar is available in 'lib' directory.

In order to submit sparkhpc job initialize your sparkhpc environment (e.g. with module load sparkhpc) and the run:

	sparkhpc-submit --class WordCountEnv -v -o output/WordCountEnv.oe  lib/tests-core_2.10-1.0.jar `pwd`/data/lady_of_shalott.txt

This will submit a jobs to the PBS queue and print out the submission script for reference (due the -v option).
You can check the status of your job with:

	qstat -u <user-name>

e.g.:
	qstat -u szu004

Once the job has finisged the joined stdout and stderr output of the job will be availble at: output/WordCountEnv.oe  (due to -o option)

You can achieve the same results running the submit-wordcount.sh script.                                                                                                                                                             
In order to find out more about running sparkhpc-submit and available options use:
	
	sparkhpc-submit -h


