#!/bin/bash

# Author: Brayan Mauricio-Gonzalez & Bryant Collins
# Assignment 2 - Create
# Purpose: Creates files that contain header information about an invoice.

# checking that the correct number of arguments were entered
if [[ $# != 2 ]]
then
  echo 'usage: create.sh -i|-o filename'
  exit 1
fi

# validating the arguments passed by the user
if [[ $1 != "-"* && $2 != "-"* ]]
then
  echo 'ERROR: needs flag'
  exit 2
elif [[ $1 == "-"* && $2 == "-"* ]]
then
  echo 'ERROR: needs filename'
  exit 3
fi

type=""
output=""

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
      echo 'ERROR: invalid flag'
      exit 4
    fi
  else
    output=$i
  fi
done

output=$output$type
# echo $output

# checking if the output file exists
if [[ -e $output ]]
then
  echo "ERROR: $output already exists"
  exit 5
fi

# prompting for the customer name
echo -n 'Please enter customer name > '
read name
echo "customer:$name" >> $output

# prompting for the customer address
echo -n 'Please enter street address > '
read street

echo -n 'Please enter city > '
read city

# checking whether to ask for a state or not
if [[ $type == ".oso" ]]
then
  echo -n 'Please enter state > '
  read state
  len=$(echo -n $state | wc -c)

  if [[ len -ne 2 ]]
  then
    echo "ERROR: $state is not the correct length for a state abbreviation: (${len// /})"
    rm $output
    exit 6
  fi
else
  state="NC"
fi

echo "address:$street, $city, $state" >> $output

# prompting for the categories until at least 1 is entered
while [[ $categories == "" ]]
do
  echo -n 'Please enter the fields that comprise the order > '
  read categories
done

echo "categories:$(echo "${categories// /,}")" >> $output

# prompting for the category amounts
items=""
for category in $categories
do
  echo -n "Please enter the number of \"$category\" items you want to purchase > "
  read num

  if [[ $(echo "${num//[0-9]/}") != "" ]]
  then
    echo "ERROR: $num is an invalid number"
    rm $output
    exit 7
  fi

  items+=$num","
done
echo "items:$(echo "${items%?}")" >> $output

# echo calling valid ?
# validating the output file
if ! ./valid.sh $output
then
  echo "ERROR: $output was invalid"
  rm $output
  exit 8
fi

echo -e "\n\"$output\" has been created for\n$(head -2 $output)"
