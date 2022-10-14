#!/bin/bash

# Author: Brayan Mauricio-Gonzalez & Bryant Collins
# Assignment 2 - Create
# Purpose: Creates files that contain header information about an invoice.

# tracking the exit code
code=0

output=""

# validating the arguments passed by the user
if [[ $# != 2 ]]; then
  echo 'usage: create.sh -i|-o filename'
  code=$(($code+1))

  exit $code
fi

type=""

if [[ $1 != "-"* && $2 != "-"* ]]
then
  echo 'error: needs flag'
  code=$(($code+3))
  exit $code
elif [[ $1 == "-"* && $2 == "-"* ]]
then
  echo 'error: needs filename'
  code=$(($code+4))
  exit $code
fi

# checking the flag entered by the user
for i in $@
do
  if [[ $i == "-"* ]]
  then
    if [[ $i == "-i" ]]
    then
      type=".iso"
    elif [[ $i == "-o" ]]
    then
      type=".oso"
    else
      echo 'error: invalid flag'
      code=$(($code+2))
      exit $code
    fi
  else
    output=$i
  fi
done

output=$output$type
echo $output
