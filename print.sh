#!/bin/bash

# Author: Brayan Mauricio-Gonzalez & Bryant Collins
# Assignment 3 - Print
# Purpose: create a table showing info inside a provided file

if [[ $# > 2 || $# < 1 ]]
then
  echo "Usage: $0 <filename> [-c]"
  exit 1
fi

# validating the input file
if ! ./valid.sh $1 > /dev/null
then
  echo "ERROR: $1 was an invalid file"
  exit 2
fi

# if -c is present sort by ascending order of total cost
if [[ $# == 2 && $2 != "-c" ]]
then
  echo "ERROR: Invalid flag"
  exit 3
fi

# get linecount for easy use
lc=$(($(grep "[^[:space:]]" $1 | wc -l) - 4))

# tack on the the total cost at the end of each line
grep "[^[:space:]]" $1 | tail -$lc | awk -F, '{$4=$2*$3;printf "%s,%.2f,%d,%.2f\n", $1, $2, $3, $4}' > tmp.txt

# sort by either the category or total cost
if [[ $# == 2 && $2 == "-c" ]]
then
  sort tmp.txt -t, -b -n -k 4 -o tmp.txt
else
  sort tmp.txt -f -o tmp.txt
fi

# the basic beginning of the latex document
table="\\\documentclass{article}\n\\\pagestyle{empty}\n\\\begin{document}\n\\\begin{center}\n\\\begin{tabular}{|rrrrr|}\n\\\hline\n"
table=$table"\multicolumn{5}{|c|}{$(grep "[^[:space:]]" $1 | head -1 | awk -F: '{print $2}')}\\\\\\\\\n"
table=$table"\multicolumn{5}{|c|}{$(grep "[^[:space:]]" $1 | head -2 | tail -1 | awk -F: '{print $2}')}\\\\\\\\\n"
table=$table"\\\hline\n"
table=$table"Category&Item&Cost&Quantity&Total\\\\\\\\\n"
table=$table"\\\hline\\\hline\n"

# loop to build each line of the latex file
i=1
while [[ $i != $(($lc+1)) ]]
do
  line=$(grep "[^[:space:]]" tmp.txt | head -$i | tail -1)
  table=$table"$(echo $line | awk -F: '{print $1}')&"
  table=$table"$(echo $line | awk -F'[:,]' '{print $2}')&"
  table=$table"$(echo $line | awk -F'[:,]' '{print $3}')&"
  table=$table"$(echo $line | awk -F'[:,]' '{print $4}')&"
  table=$table"$(echo $line | awk -F'[:,]' '{print $5}')\\\\\\\\\n"
  i=$(($i+1))
done

# basic end of a latex file
table=$table"\\\hline\n"
table=$table"\\\end{tabular}\n\\\end{center}\n\\\end{document}"

# copy stuff into a temp tex file, then compile and cleanup
# piping into /dev/null cause I don't care about the compile messages
echo -e $table > tmp.tex
pdflatex tmp.tex &> /dev/null && rm tmp.aux tmp.log

# view file
okular tmp.pdf

# cleanup
rm tmp.txt tmp.tex tmp.pdf
