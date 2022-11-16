#!/bin/bash
if [[ $# > 2 || $# < 1 ]]
then
  echo "Usage: $0 <filename> -c"
  exit 1
fi

# if -c is present sort by ascending order of total cost
if [[ $# == 2 && $2 != "-c" ]]
then
  echo "Invalid flag"
  exit 2
fi

if [[ $# == 2 && $2 == "-c" ]]
then
  numSort=1
else
  numSort=0
fi

lc=$(($(grep . $1 | wc -l) - 4))

grep . $1 | tail -$lc > tmp.txt

temp=""

for i in $(grep . tmp.txt | awk -F, '{printf "%s,%.2f,%d\n", $1, $2, $3}' )
do
  echo $i
  if [[ $numSort == 1 ]]
  then
    temp=$temp"$(echo $i | awk -F, '{$4=$2 * $3;printf "%.2f,%s,%.2f,%d", $4, $1, $2, $3}')\n"
  else
    temp=$temp"$(echo $i | awk -F, '{$4=$2 * $3;printf "%s,%.2f,%d,%.2f", $1, $2, $3, $4}')\n"
  fi
done

if [[ $numSort == 1 ]]
then
  echo -e $temp | grep . | sort -n > tmp.txt
  temp2=""
  for i in $(cat tmp.txt)
  do
    temp2=$temp2"$(echo $i | awk -F, '{printf "%s,%.2f,%d,%.2f", $2, $3, $4, $1}')\n"
  done
  echo -e $temp2 | grep . > tmp.txt
else
  echo -e $temp | grep . | sort > tmp.txt
fi

table="\\\documentclass{article}\n\\\pagestyle{empty}\n\\\begin{document}\n\\\begin{center}\n\\\begin{tabular}{|rrrrr|}\n\\\hline\n"
table=$table"\multicolumn{5}{|c|}{$(grep . $1 | head -1 | awk -F: '{print $2}')}\\\\\\\\\n"
table=$table"\multicolumn{5}{|c|}{$(grep . $1 | head -2 | tail -1 | awk -F: '{print $2}')}\\\\\\\\\n"
table=$table"\\\hline\n"
table=$table"Category&Item&Cost&Quantity&Total\\\\\\\\\n"
table=$table"\\\hline\\\hline\n"

i=1
while [[ $i != $(($lc+1)) ]]
do
  line=$(grep . tmp.txt | head -$i | tail -1)
  table=$table"$(echo $line | awk -F: '{print $1}')&"
  table=$table"$(echo $line | awk -F'[:,]' '{print $2}' | sed 's/^ //')&"
  table=$table"$(echo $line | awk -F'[:,]' '{print $3}' | sed 's/^ //')&"
  table=$table"$(echo $line | awk -F'[:,]' '{print $4}' | sed 's/^ //')&"
  table=$table"$(echo $line | awk -F'[:,]' '{print $5}' | sed 's/^ //')\\\\\\\\\n"
  i=$(($i+1))
done

table=$table"\\\hline\n"

table=$table"\\\end{tabular}\n\\\end{center}\n\\\end{document}"

echo -e $table > tmp.tex
pdflatex tmp.tex &> /dev/null  && rm tmp.aux tmp.log
okular tmp.pdf

#rm tmp.txt tmp.tex tmp.pdf
