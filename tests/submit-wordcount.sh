#!/bin/bash

set -e

rm -f WordCount.oe

../bin/sparkhpc-submit --class WordCount \
 --conf spark.logConf=true \
 -v  core/target/tests-core_2.10-1.0.jar `pwd`/data/lady_of_shalott.txt

