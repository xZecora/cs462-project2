#!/bin/bash

# Author: Brayan Mauricio-Gonzalez & Bryant Collins
# Assignment 2 - Create
# Purpose: Creates files that contain header information about an invoice.

# tracking the exit status
status=0

# validating the arguments passed by the user
if [[ $# != 2 ]]; then
  echo 'usage: create.sh -i|-o filename'
  status=$(($status + 1))

  exit $status
fi

type=""

# checking the flag entered by the user
if [[ $1 == "-i" ]]
then
  type = ".iso"
elif [[ $1 == "-o" ]]
then
  type = ".oso"
else
  echo 'error: invalid flag'
  status=$(($status + 2))

  exit $status
fi
