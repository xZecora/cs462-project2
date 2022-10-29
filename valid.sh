#!/bin/bash

# Author: Brayan Mauricio-Gonzalez & Bryant Collins
# Assignment 2 - Valid
# Purpose: Validates files containing header information about an invoice.

# validating the command line argument
if [[ $# != 1 ]]
then
  echo "Usage: $0 <file>"
  exit 1
fi

if [[ ! -r $1 ]]
then
  echo "ERROR: $1 is not accessible"
  exit 2
fi

if [[ $1 != *'.'* ]]
then
  echo "ERROR: $1 does not have an extension"
  exit 2
fi

if [[ $1 != *'.iso' && $1 != *'.oso' ]]
then
  echo "ERROR: \".$(echo $1 | cut -d. -f2)\" is not a valid file extension"
  exit 2
fi

# validating the customer header line
customer=$(grep "[^[:space:]]" $1 | head -1)
if [[ $(echo $customer | grep "customer:[^[:space:]]") == '' ]]
then
  if [[ $customer == '' ]]
  then
    echo "ERROR: Missing customer header line"
  else
    echo "ERROR: Invalid customer header line, must be of the form 'customer:<name>'"
  fi
  exit 3
fi

# validating the address header line
address=$(grep "[^[:space:]]" $1 | head -2 | tail -1)
if [[ $(echo -n $address | grep -E "address:[0-9]+ [A-Za-z]+( [A-Za-z]+)*, [A-Za-z]+( [A-Za-z]+)*, [A-Za-z]+") == '' ]]
then
  if [[ $address == $customer ]]
  then
    echo -e "ERROR: Missing header line\nLast header line: $customer"
  else
    echo "ERROR: Invalid address header line, must be of the form 'address:NNN STREET NAME, CITY, ST'"
  fi
  exit 4
fi

# checking state length
if [[ $(echo -n $address | awk -F, '{print $3}' | tr -d "\n " | wc -c) -ne 2 ]]
then
  echo "'$(echo -n $address | awk -F, '{print $3}' | tr -d "\n ")' is the wrong length for a state abbreviation"
  exit 4
fi

# checking state for in-state vs out-of-state
if [[ $1 == *'.iso' ]]
then
  if [[ $(echo -n $address | awk -F, '{print $3}' | tr -d "\n " | grep -i "NC") == '' ]]
  then
    echo "ERROR: Invalid state for an iso file, must be 'NC'"
    exit 4
  fi
else
  if [[ $(echo -n $address | awk -F, '{print $3}' | tr -d "\n " | grep -i "NC") != '' ]]
  then
    echo "ERROR: Invalid state for an oso file, must be not be 'NC'"
    exit 4
  fi
fi

# validating the categories header line
categories=$(grep "[^[:space:]]" $1 | head -3 | tail -1)
if [[ $(echo $categories | grep -E "categories:[A-Za-z]+(,[A-Za-z]+)*$") == '' ]]
then
  if [[ $categories == $address ]]
  then
    echo -e "ERROR: Missing header line\nLast header line: $address"
  else
    echo "ERROR: Invalid categories header line, must be of the form 'categories:<category>[,<category>]*'"
  fi
  exit 5
fi

# making sure no keywords are used as a category name
if [[ $(echo -n $categories | awk -F: '{print $2}') == *[Cc][Uu][Ss][Tt][Oo][Mm][Ee][Rr]* ]]
then
  echo "ERROR: Cannot use the 'customer' keyword as category"
  exit 5
fi

if [[ $(echo -n $categories | awk -F: '{print $2}') == *[Aa][Dd][Dd][Rr][Ee][Ss][Ss]* ]]
then
  echo "ERROR: Cannot use 'address' keyword as a category"
  exit 5
fi

if [[ $(echo -n $categories | awk -F: '{print $2}') == *[Cc][Aa][Tt][Ee][Gg][Oo][Rr][Ii][Ee][Ss]* ]]
then
  echo "ERROR: Cannot use 'categories' keyword as a category"
  exit 5
fi

if [[ $(echo -n $categories | awk -F: '{print $2}') == *[Ii][Tt][Ee][Mm][Ss]* ]]
then
  echo "ERROR: Cannot use the 'items' keyword as a category"
  exit 5
fi

# validating the items header line
items=$(grep "[^[:space:]]" $1 | head -4 | tail -1)
if [[ $(echo -n $items | grep -E "items:[0-9]+(,[0-9]+)*$") == '' ]]
then
  if [[ $items == $categories ]]
  then
    echo -e "ERROR: Missing header line\nLast header line: $categories"
  else
    echo "ERROR: Invalid items header line, must be of the form 'items:<num>[,<num>]*'"
  fi
  exit 6
fi

# checking that the number of categories matches the number of items
num_categories=$(echo -n $categories | awk -F, '{print NF}')
num_items=$(echo -n $items | awk -F, '{print NF}')
if [[ $num_categories != $num_items ]]
then
  echo "ERROR: invalid item quantities: $num_categories categories but $num_items items"
  exit 6
fi

if [[ $(grep "[^[:space:]]" $1 | head -5 | tail -1) != $items ]]
then
  echo "ERROR: unnecessary lines at the end of the file"
  exit 7
fi
