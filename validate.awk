BEGIN{ line = 0 }
{
    line++

    if ($2 ~ /[0-9]+(\.[0-9][0-9])?$/ && $3 ~ /[0-9]+$/){
        $4=$2*$3;
        printf "%s,%.2f,%d,%.2f\n", $1, $2, $3, $4
    }else{
        printf "Invalid number on line %d\n", line
    }
}
