#!/bin/bash

YAML=$(js-yaml $1)

FILENAME=$(basename -- $1)
FILENAME="${FILENAME%.*}"

KEY=($(echo $YAML | jq -r -c 'to_entries | .[].key'))

IFS="|" read -r -a VALUE <<< "$(echo $YAML | jq -r -c '[to_entries | .[].value | tostring] | join("|")')"

for k in "${!KEY[@]}"
do
  CMD=${KEY[$k]}'=''${VALUE[$k]}'''

  eval $CMD
done

INPUT_KEY=($(echo $INPUT | jq -r -c '.[] | to_entries[] | .key'))

for k in "${!INPUT_KEY[@]}"
do
  CMD='VALUE=$'''$((k+2))''
  
  eval $CMD

  SUBTITLE="$SUBTITLE&${INPUT_KEY[$k]}=$VALUE"

  SQL=$(echo $SQL | sed "s/:${INPUT_KEY[$k]}/$VALUE/g")
done

SUBTITLE=${SUBTITLE:1:${#SUBTITLE}}

case $CHART in
  "column")
    TMP=$(echo $OUTPUT | jq -r -c 'to_entries[]')
    AXIS_COLUMN=($(echo $TMP | jq -r -c '.value.COLUMN'))
    AXIS_TEXT=($(echo $TMP | jq -r -c '.value.TEXT'))

    XCOLUMN=${AXIS_COLUMN[0]}
    YCOLUMN=${AXIS_COLUMN[1]}
    XTEXT=${AXIS_TEXT[0]}
    YTEXT=${AXIS_TEXT[1]}

    impala-shell --print_header -B -o /dev/stdout --quiet -q "$SQL" | 
    csvtojson --delimiter='\t' |
    ./jsontohighcharts "$FILENAME" "$SUBTITLE" "$XTEXT" "$YTEXT" $CHART $XCOLUMN $YCOLUMN |
    highcharts-export-server --infile /dev/stdin --outfile ../public/generated/$FILENAME/$SUBTITLE.png
    ;;
  "pie")
    TMP=($(echo $OUTPUT | jq -r -c '.NAME, .VALUE'))
    OUTPUT_NAME=${TMP[0]}
    OUTPUT_VALUE=${TMP[1]}

    impala-shell --print_header -B -o /dev/stdout --quiet -q "$SQL" | 
    csvtojson --delimiter='\t' |
    ./jsontohighcharts "$FILENAME" "$SUBTITLE" "$XTEXT" "$YTEXT" $CHART $OUTPUT_NAME $OUTPUT_VALUE |
    highcharts-export-server --infile /dev/stdin --outfile ../public/generated/$FILENAME/$SUBTITLE.png
    ;;
esac
