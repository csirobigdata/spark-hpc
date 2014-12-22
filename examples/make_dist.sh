#!/bin/bash

mvn package
mkdir -p lib
cp target/*.jar lib
mvn clean
