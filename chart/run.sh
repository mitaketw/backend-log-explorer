#!/bin/bash

YAML=$(js-yaml chart.yml)

KEY=($(echo $YAML | jq -r -c 'to_entries | .[].key'))

IFS="|" read -r -a VALUE <<< "$(echo $YAML | jq -r -c '[to_entries | .[].value | tostring] | join("|")')"

for k in "${!KEY[@]}"
do
  CMD=${KEY[$k]}'=''${VALUE[$k]}'''

  eval $CMD
done

#echo $TITLE
#echo $DESCRIPTION
#echo $SQL
#echo $INPUT
#echo $OUTPUT

#impala-shell --print_header -B -o /dev/stdout --quiet -f /dev/stdin | 
#csvtojson --delimiter='\t' |
#./jsontohighcharts |
#highcharts-export-server --infile /dev/stdin --outfile test.png
