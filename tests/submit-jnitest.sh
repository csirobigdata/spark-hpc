#!/bin/bash
rm -f JniTestSubmited.oe
../bin/sparkhpc-submit -v --class  JniTestEnv \
	--jars jni/target/tests-jni-1.0.jar \
	--driver-memory 2 \
	--executor-memory 2 \
	--driver-class-path log4jx \
	--driver-library-path jni-native/target \
	--conf spark.hpc.test=value \
	--output JniTestSubmited.oe \
	core/target/tests-core_2.10-1.0.jar \
	`pwd`/data/lady_of_shalott.txt 

#	--driver-java-options ' -Dspark.hpc.test=value' \
