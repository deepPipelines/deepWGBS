me=generateMetadata.sh

printHelp() {
 echo -e "Usage: `basename $0`" >&2
 echo -e "" >&2
 echo -e " Mandatory:" >&2
 echo -e "  -i INPUTFILE\tInput BAM file" >&2
 echo -e "  -t FOLDER\tTemporary folder. This should be the one in which the analysis was made... That is NOT the same as the output folder" >&2
 echo -e "  -p FILE\tParameterfile" >&2
 echo -e "  -f FILE\tFlagstats file" >&2
 echo -e "  -m FILE\tPicarddupmetrics file">&2
}

while getopts ":hi:t:p:f:m:" opt
do
 case "$opt" in
  h) printHelp; exit 1 ;;
  i) LOCALINPUTFILE="$OPTARG" ;;
  t) TMPWD="$OPTARG" ;;
  p) PARAMETERFILE="$OPTARG" ;;
  f) INPUTFILE_PICARDDUPMETRICS="$OPTARG";;
  m) INPUTFILE_FLAGSTATS="$OPTARG";;
  *) printHelp; exit 1 ;;
 esac
done

if [[ -z "$LOCALINPUTFILE" ]] || [[ -z "$TMPWD" ]] || [[ -z "$PARAMETERFILE" ]]||[[ -z "$INPUTFILE_PICARDDUPMETRICS"]]||[[ -z "$INPUTFILE_FLAGSTATS"]]
then 
 echo "" >&2
 echo "ERROR: All arguments must be set" >&2
 echo "" >&2
 printHelp
 exit 1
fi

source $PARAMETERFILE
set -o pipefail

rs='\n'
fs='\t'

exitSum=0


echo "LOGG ($name): `date` START" >&2

printf "${rs}filename${fs}%s,%s,%s" "$INPUTFILE" "${INPUTFILE_PICARDDUPMETRICS}" "${INPUTFILE_FLAGSTATS}"

if [[ -f "${INPUTFILE_PICARDDUPMETRICS}" ]]
then
awk -vOFS=$fs -vORS=$rs '$2=="METRICS" {state=1;next} state==1 {colNr=NF;state=2;next} state==2 && (NF==colNr || NF==colNr-1) {curRead=$2+2*$3;totRead+=curRead;dupRead+=$5+2*$6}  END {printf "%sduplication_rate%s%s",ORS,OFS,dupRead/totRead}' ${INPUTFILE_PICARDDUPMETRICS}
exitSum=$(( $exitSum + $? ))
elif [ "$MARKDUP" == "T" ]
then
awk -vOFS=$fs -vORS=$rs '$2=="METRICS" {state=1;next} state==1 {colNr=NF;state=2;next} state==2 && (NF==colNr || NF==colNr-1) {curRead=$2+2*$3;totRead+=curRead;dupRead+=$5+2*$6}  END {printf "%sduplication_rate%s%s",ORS,OFS,dupRead/totRead}' $OUTFOLDER/$OUTNAME.markduplicate.metrics.csv
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

