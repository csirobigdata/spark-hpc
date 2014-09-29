#!/bin/bash

set -e

../bin/sparkhpc-submit --class WordCountEnv -v  core/target/tests-core_2.10-1.0.jar `pwd`/data/lady_of_shalott.txt

