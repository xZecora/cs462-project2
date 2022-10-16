#!/bin/bash

# Author: Brayan Mauricio-Gonzalez & Bryant Collins
# Assignment 2 - Valid
# Purpose: Validates files containing header information about an invoice.

perms=0

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

if [[ -r $1 && -x $1 && -w $1 ]]
then
  perms=1
fi

if [[ $1 == *'.iso' ]]
then
  echo "its an iso"
  if [[ $(grep . $1 | head -2 | awk -F, '{print $3}') != *'NC' ]]
  then
    echo "Invalid state for iso, must be 'NC'"
    exit 3
  fi
fi

if [[ $1 == *'.oso' ]]
then
  echo "its an oso"
  if [[ $(grep . $1 | head -2 | tail -1 | awk -F, '{print $3}') == *'NC' ]]
  then
    echo "Invalid state for iso, must be not be 'NC'"
    exit 4
  fi
fi

if [[ $(grep . $1 | head -1 | awk -F: '{print $1}') != 'customer' ]]
then
  echo 'Invalid first line'
  exit 5
fi

if [[ $(grep . $1 | head -2 | tail -1 | awk -F: '{print $1}') != 'address' || $(grep . $1 | head -2 | tail -1 | awk -F: '{print NF}') != 2 ]]
then
  echo 'Invalid second line'
  exit 6
fi

if [[ $(grep . $1 | head -2 | tail -1  | awk -F, '{print NF}') != 3 ]]
then
  echo 'Invalid address line'
  exit 7
fi

if [[ $(grep . $1 | head -3 | tail -1 | awk -F: '{print $1}') != 'categories' || $(grep . $1 | head -3 | tail -1 | awk -F: '{print NF}') != 2 ]]
then
  echo 'Invalid third line'
  exit 7
fi

if [[ $(grep . $1 | head -4 | tail -1 | awk -F: '{print $1}') != 'items' || $(grep . $1 | head -4 | tail -1 | awk -F: '{print NF}') != 2 ]]
then
  echo 'Invalid fourth line'
  exit 8
fi

if [[ $(grep . $1 | head -3 | tail -1 | awk -F, '{print NF}') > $(grep . $1 | head -4 | tail -1 | awk -F, '{print NF}') ]]
then
  echo 'less items than categories'
  exit 9
fi

echo "Oh shit, didn't know you were valid like that"
