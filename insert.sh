#!/bin/bash

# Author: Brayan Mauricio-Gonzalez & Bryant Collins
# Assignment 3 - Insert
# Purpose: Inserts record(s) into a text invoice file

# checking for correct number of arguments
if [[ $# < 1 || $# > 2 ]]
then
  echo "usage: $0 <filename> [category]"
  exit 1
fi

# validating the input file
if ! ./valid.sh $1 > /dev/null
then
  echo "ERROR: $1 was an invalid file"
  exit 2
fi

# checking that we can write to the file
if [[ ! -w "$1" ]]
then
  echo "ERROR: $1 is not writable"
  exit 3
fi

# grabbing the categories from the input file
categories=$(grep "categories:" $1 | cut -d":" -f2 | tr "," "|")
# grabbing the item counts from the input file and placing them into an array
items=($(grep "items:" $1 | cut -d":" -f2 | tr "," " "))

# checking if a 2nd argument was given
if [[ "$2" ]]
then
  # checking if the 2nd argument is a valid category
  if [[ ! $(echo "$2" | grep -iE "($categories)$") ]]
  then
    echo "$2 is not a valid category for this invoice"
    exit 4
  else
    # converting to all lowercase
    categories=$(echo "$categories" | tr "|" " " | tr '[:upper:]' '[:lower:]')
    category=$(echo "$2" | tr '[:upper:]' '[:lower:]')
    # getting the position of the category given
    pos=$(echo "${categories//$category/:}" | cut -d":" -f1 | wc -w)
    # changing categories into an array
    categories=($2)
    # getting the category's item count
    items=(${items[$pos]})
  fi
else
  # checking all categories since 2nd argument was not supplied
  categories=($(echo "$categories" | tr "|" " "))
fi

# echo ${categories[@]}
# echo ${items[@]}
# tracking the number of records added
records=0

# echo "" >> $1 # for spacing ?

# looping through the categories
for i in ${!categories[@]}
do
  # getting the number of entries that already exist for the current category
  entries=$(cat "$1" | grep -i "${categories[$i]}:" | wc -l)

  j=0
  # only inserting for missing records
  while [[ $j < $((${items[$i]} - $entries)) ]]
  do
    # prompting for the info for a single record
    while [[ $name == "" ]];
    do
      echo -n "Please enter the name of a ${categories[$i]} item > "
      read name
    done

    echo -n "Please enter a price per unit of $name > "
    read price
    # validating price entered
    if [[ ! $(echo "$price" | grep -E "^[0-9]+(\.[0-9][0-9])?$") ]]
    then
      echo "ERROR: $price is an invalid price"
      echo -e "\n$records records added to \"$1\" invoice"
      exit 5
    fi

    echo -n "Please enter the amount of $name units to purchase > "
    read units
    # validating units entered
    if [[ $(echo "${units//[0-9]/}") != "" ]]
    then
      echo "ERROR: $units is an invalid number of units"
      echo -e "\n$records records added to \"$1\" invoice"
      exit 5
    fi

    # appending record to the invoice file
    echo "${categories[$i]}: $name, $price, $units" >> $1
    echo "" # for spacing

    j=$(($j+1))
    records=$(($records+1))
  done
done

# displaying how many records were added to user
echo "$records records added to \"$1\" invoice"
