#!/bin/bash

# Author: Brayan Mauricio-Gonzalez & Bryant Collins
# Assignment 2 - Create
# Purpose: Creates files that contain header information about an invoice.

# tracking the exit code
code=0

# checking that the correct number of arguments were entered
if [[ $# != 2 ]]; then
  echo 'usage: create.sh -i|-o filename'
  code=$(($code+1))

  exit $code
fi

# validating the arguments passed by the user
if [[ $1 != "-"* && $2 != "-"* ]]; then
  echo 'ERROR: needs flag'
  code=$(($code+2))

  exit $code
elif [[ $1 == "-"* && $2 == "-"* ]]; then
  echo 'ERROR: needs filename'
  code=$(($code+3))

  exit $code
fi ## check file name for extension

type=""
output=""

# checking the flag entered by the user
for i in $@; do
  if [[ $i == "-"* ]]; then
    if [[ $i == "-i" ]]; then
      type=".iso"
    elif [[ $i == "-o" ]]; then
      type=".oso"
    else
      echo 'ERROR: invalid flag'
      code=$(($code+4))

      exit $code
    fi
  else
    output=$i
  fi
done

output=$output$type
# echo $output

# checking if the output file exists
if [[ -e $output ]]; then
  echo "ERROR: $output already exists"
  code=$(($code+5))

  exit $code
fi

echo -n 'Please enter customer name > '
read name
echo "customer:$name" >> $output

echo -n 'Please enter street address > '
read street

echo -n 'Please enter city > '
read city

if [[ $type == ".oso" ]]; then
  echo -n 'Please enter state > '
  read state
  len=$(echo -n $state | wc -c)

  if [[ len -ne 2 ]]; then
    echo "ERROR: $state is not the correct length for a state abbreviation: (${len// /})"
    rm $output
    code=$(($code+6))

    exit $code
  fi
else
  state="NC"
fi

echo "address:$street, $city, $state" >> $output

while [[ $categories == "" ]]; do
  echo -n 'Please enter the fields that comprise the order > '
  read categories
done

echo "categories:$(echo "${categories// /,}")" >> $output

items=""
for category in $categories; do
  echo -n "Please enter the number of \"$category\" items you want to purchase > "
  read num

  if [[ $(echo "${num//[0-9]/}") != "" ]]; then
    echo "ERROR: $num is an invalid number"
    rm $output
    code=$(($code+7))

    exit $code
  fi

  items+=$num","
done
echo "items:$(echo "${items%?}")" >> $output

# validating the output file
# echo calling valid ?
if ! ./valid.sh $output; then
  echo "ERROR: $output was invalid"
  rm $output
  code=$(($code+8))

  exit $code
fi

echo -e "\n\"$output\" has been created for\n$(head -2 $output)"
