#!/usr/bin/env bash

name=genMetaPic.sh

printHelp() {
 echo -e "Usage: `basename $0`" >&2
 echo -e "" >&2
 echo -e " Mandatory:" >&2
 echo -e "  -n FILE\tInputfile" >&2
 echo -e "  -d FILE\tPicarddupmetrics file">&2
 echo -e "  -f FILE\tFlagstats file">&2
 echo -e "  -o STRING\tOutput name">&2
}

while getopts ":h:p:d:f:o:" opt
do
 case "$opt" in
  h) printHelp; exit 1 ;;
  n) INPUTFILE="$OPTARG" ;;
  d) INPUTFILE_PICARDDUPMETRICS="$OPTARG";;
  f) INPUTFILE_FLAGSTATS="$OPTARG";;
  o) output_name="$OPTARG";;
  *) printHelp; exit 1 ;;
 esac
done

if [[ -z "$INPUTFILE" ]]||[[ -z "$INPUTFILE_PICARDDUPMETRICS"]]||[[ -z "$INPUTFILE_FLAGSTATS"]]||[[ -z "$output_name"]]
then 
 echo "" >&2
 echo "ERROR: All arguments must be set" >&2
 echo "" >&2
 printHelp
 exit 1
fi

set -o pipefail

rs='\n'
fs='\t'

exitSum=0

echo "LOGG ($name): `date` START" >&2

printf "${rs}filename${fs}%s,%s,%s" "$INPUTFILE" "${INPUTFILE_PICARDDUPMETRICS}" "${INPUTFILE_FLAGSTATS}"

if [[ -f "$(INPUT_PICARDDUPMETRICS)"]]
then
awk -vOFS=$fs -vORS=$rs '$2=="METRICS" {state=1;next} state==1 {colNr=NF;state=2;next} state==2 && (NF==colNr || NF==colNr-1) {curRead=$2+2*$3;totRead+=curRead;dupRead+=$5+2*$6}  END {printf "%sduplication_rate%s%s",ORS,OFS,dupRead/totRead}' ${INPUTFILE_PICARDDUPMETRICS}
exitSum=$(( $exitSum + $? ))
fi

if [[ -f "${INPUTFILE_FLAGSTATS}" ]]
then
awk -vOFS=$fs -vORS=$rs 'NR==1 {printf "%snum_reads%s%s",ORS,OFS, $1+$3;exit}' ${INPUTFILE_FLAGSTATS}
exitSum=$(( $exitSum + $? ))

awk -vOFS=$fs -vORS=$rs 'NR==1 {tot=$1+$3} $4=="mapped" {printf "%snum_mapped_reads%s%s",ORS,OFS,$1+$3}' ${INPUTFILE_FLAGSTATS}
exitSum=$(( $exitSum + $? ))
else
 printf "${rs}num_reads${fs}NA${rs}num_mapped_reads${fs}NA"
fi

printf "${rs}"

echo "LOGG ($name): `date` DONE" >&2

exit $exitSum

