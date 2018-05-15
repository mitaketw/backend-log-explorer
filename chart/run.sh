#!/bin/sh

YAML=$(js-yaml chart.yml)

SQL=$(echo $YAML | jq -r -c '.SQL')
TITLE=$(echo $YAML | jq -r -c '.TITLE')
DESCRIPTION=$(echo $YAML | jq -r -c '.DESCRIPTION')
INPUT=$(echo $YAML | jq -r -c '.INPUT[]')

echo $DESCRIPTION
echo $TITLE
echo $SQL
echo $INPUT

#impala-shell --print_header -B -o /dev/stdout --quiet -f /dev/stdin | 
#csvtojson --delimiter='\t' |
#./jsontohighcharts |
#highcharts-export-server --infile /dev/stdin --outfile test.png
