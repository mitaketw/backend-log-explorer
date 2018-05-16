#!/bin/bash

YAML=$(js-yaml chart.yml)

KEY=($(echo $YAML | jq -r -c 'to_entries | .[].key'))

IFS="|" read -r -a VALUE <<< "$(echo $YAML | jq -r -c '[to_entries | .[].value | tostring] | join("|")')"

for k in "${!KEY[@]}"
do
  CMD=${KEY[$k]}'=''${VALUE[$k]}'''

  eval $CMD
done

TMP=$(echo $INPUT | jq -r -c '.[] | to_entries')
VAR_INPUT_KEY=($(echo $TMP | jq -r -c '.[].key'))
VAR_INPUT_VALUE=($(echo $TMP | jq -r -c '.[].value'))

for k in "${!VAR_INPUT_KEY[@]}"
do
  CMD='VALUE='''${VAR_INPUT_VALUE[$k]}''
  
  eval $CMD

  SQL=$(echo $SQL | sed "s/:${VAR_INPUT_KEY[$k]}/$VALUE/g")
done

echo $TITLE
echo $DESCRIPTION
echo $SQL
echo $INPUT
echo $OUTPUT

impala-shell --print_header -B -o /dev/stdout --quiet -q "$SQL" | 
csvtojson --delimiter='\t' |
./jsontohighcharts |
highcharts-export-server --infile /dev/stdin --outfile test.png
