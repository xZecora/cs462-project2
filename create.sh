#/bin/bash
type = ""

if [[ $1 == "-i" ]]
then
  type = ".iso"
elif [[ $1 == "-o" ]]
then
  type = ".oso"
else
  exit 1
fi
