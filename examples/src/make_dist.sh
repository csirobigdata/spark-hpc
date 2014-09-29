#!/bin/bash

(cd core ; mvn package)
mkdir -p ../lib
cp core/target/*.jar ../lib
(cd core; mvn clean)
