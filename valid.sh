#!/bin/bash

# Author: Brayan Mauricio-Gonzalez & Bryant Collins
# Assignment 2 - Valid
# Purpose: Validates files containing header information about an invoice.

if [[ $# != 1 ]]
then
  echo "Usage: $0 <file>"
  exit 1
fi

if [[ $1 != *'.iso' && $1 != *'.oso' ]]
then
  echo "File is not of the correct format"
  exit 2
fi

if [[ ! -f $1 ]]
then
  echo "$1 does not exist"
  exit 3
fi

if [[ ! -r $1 ]]
then
  echo "$1 is not readable"
  exit 4
fi

if [[ $1 == *'.iso' ]]
then
  if [[ $(grep . $1 | head -2 | awk -F, '{print $3}') != *'NC' ]]
  then
    echo "Invalid state for iso, must be 'NC'"
    exit 5
  fi
fi

if [[ $1 == *'.oso' ]]
then
  if [[ $(grep . $1 | head -2 | tail -1 | awk -F, '{print $3}') == *'NC' ]]
  then
    echo "Invalid state for oso, must be not be 'NC'"
    exit 6
  fi
fi

if [[ $(grep . $1 | head -2 | tail -1 | awk -F, '{print $3}' | tr -d "\n " | wc -c) != 2 ]]
then
  echo "'$(grep . $1 | head -2 | tail -1 | awk -F, '{print $3}' | tr -d "\n ")' is the wrong length for a state abbreviation"
  exit 7
fi


if [[ $(grep . $1 | head -1 | awk -F: '{print $1}') != 'customer' ]]
then
  echo "Invalid first line, must start with 'customer'"
  exit 8
fi

if [[ $(grep . $1 | head -2 | tail -1 | awk -F: '{print $1}') != 'address' || $(grep . $1 | head -2 | tail -1 | awk -F: '{print NF}') != 2 ]]
then
  echo "Invalid second line, must start with 'address'"
  exit 9
fi

if [[ $(grep . $1 | head -2 | tail -1  | awk -F, '{print NF}') != 3 ]]
then
  echo 'Invalid address line, must be of the form NNN STREET NAME, CITY, ST'
  exit 10
fi

if [[ $(grep . $1 | head -3 | tail -1 | awk -F: '{print $1}') != 'categories' || $(grep . $1 | head -3 | tail -1 | awk -F: '{print NF}') != 2 ]]
then
  echo "Invalid third line, must start with 'categories'"
  exit 11
fi

if [[ $(grep . $1 | head -4 | tail -1 | awk -F: '{print $1}') != 'items' || $(grep . $1 | head -4 | tail -1 | awk -F: '{print NF}') != 2 ]]
then
  echo "Invalid fourth line, must start with 'items'"
  exit 12
fi

if [[ $(grep . $1 | head -3 | tail -1 | awk -F, '{print NF}') > $(grep . $1 | head -4 | tail -1 | awk -F, '{print NF}') ]]
then
  echo 'There are less items than categories'
  exit 13
fi

if [[ $(grep . $1 | head -1 | awk -F: '{print $2}') == *[Cc]ustomer* ]]
then
  echo "Cannot use 'customer' keyword"
  exit 14
fi

if [[ $(grep . $1 | head -2 | tail -1 | awk -F: '{print $2}') == *[Aa]ddress* ]]
then
  echo "Cannot use 'address' keyword"
  exit 15
fi

if [[ $(grep . $1 | head -3 | tail -1 | awk -F: '{print $2}') == *[Cc]ategories* ]]
then
  echo "Cannot use 'categories' keyword"
  exit 16
fi

if [[ $(grep . $1 | head -4 | tail -1 | awk -F: '{print $2}') == *[Ii]tems* ]]
then
  echo "Cannot use 'items' keyword"
  exit 17
fi

echo "Oh shit, didn't know you were valid like that"
exit 0
