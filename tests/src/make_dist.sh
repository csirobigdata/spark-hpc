#!/bin/bash

mvn package
cp core/target/*.jar ../lib
mvn clean
