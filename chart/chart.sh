#!/bin/bash

YAML=$(js-yaml $1)

KEY=($(echo $YAML | jq -r -c 'to_entries | .[].key'))

IFS="|" read -r -a VALUE <<< "$(echo $YAML | jq -r -c '[to_entries | .[].value | tostring] | join("|")')"

for k in "${!KEY[@]}"
do
  CMD=${KEY[$k]}'=''${VALUE[$k]}'''

  eval $CMD
done

INPUT_KEY=($(echo $INPUT | jq -r -c '.[]'))

for k in "${!INPUT_KEY[@]}"
do
  CMD='VALUE=$'''$((k+2))''
  
  eval $CMD

  SQL=$(echo $SQL | sed "s/:${INPUT_KEY[$k]}/$VALUE/g")
done

TMP=($(echo $OUTPUT | jq -r -c '.[] | .X + .Y'))
XAXIS=${TMP[0]}
YAXIS=${TMP[1]}

echo $TITLE
echo $DESCRIPTION
echo $SQL
echo $INPUT
echo $OUTPUT

impala-shell --print_header -B -o /dev/stdout --quiet -q "$SQL" | 
csvtojson --delimiter='\t' |
./jsontohighcharts $XAXIS $YAXIS |
highcharts-export-server --infile /dev/stdin --outfile ../public/generated/$TITLE.png
