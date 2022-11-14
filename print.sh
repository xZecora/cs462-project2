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

table="\\\documentclass{article}\n\\\pagestyle{empty}\n\\\begin{document}\n\\\begin{center}\n\\\begin{tabular}{|rrrrr|}\n\\\hline\n"
table=$table"\multicolumn{5}{|c|}{$(grep . $1 | head -1 | awk -F: '{print $2}')}\\\\\\\\\n"
table=$table"\multicolumn{5}{|c|}{$(grep . $1 | head -2 | tail -1 | awk -F: '{print $2}')}\\\\\\\\\n"
table=$table"\\\hline\n"
table=$table"Category&Item&Cost&Quantity&Total\\\\\\\\\n"
table=$table"\\\hline\\\hline\n"
lc=$(($(grep . $1 | wc -l) - 4))

i=1
while [[ $i != $(($lc+1)) ]]
do
  line=$(grep . $1 | head -$((4+$i)) | tail -1)
  table=$table"$(echo $line | awk -F: '{print $1}')&"
  table=$table"$(echo $line | awk -F'[:,]' '{gsub(/^ /,"",$2);print $2}')&"
  table=$table"$(echo $line | awk -F'[:,]' '{gsub(/^ /,"",$3);print $3}')&"
  table=$table"$(echo $line | awk -F'[:,]' '{gsub(/^ /,"",$4);print $4}')&"
  table=$table"$(echo $(echo $line | awk -F'[:,]' '{gsub(/^ /,"",$4);print $4}')*$(echo $line | awk -F'[:,]' '{gsub(/^ /,"",$4);print $3}') | bc)\\\\\\\\\n"
  i=$(($i+1))
done

table=$table"\\\hline\n"

table=$table"\\\end{tabular}\n\\\end{center}\n\\\end{document}"

echo -e $table > tmp.tex
pdflatex tmp.tex  &> /dev/null && rm tmp.aux tmp.log
zathura tmp.pdf

rm tmp.tex tmp.pdf

# redirect error to /dev/null cause it still works and throws a pointless error
#echo -e $table | tbl | groff > trying.ps
#okular trying.ps
#rm trying.ps

#groff output >> output.ps
#okular output.ps
