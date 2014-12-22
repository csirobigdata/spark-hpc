#!/bin/bash
set -e
sparkhpc-submit --class WordCount -v -o output/WordCount.oe  lib/tests-core_2.10-1.0.jar `pwd`/data/lady_of_shalott.txt

