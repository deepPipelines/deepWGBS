#!/usr/bin/env bash

name=genMetaBam.sh

printHelp() {
 echo -e "Usage: `basename $0`" >&2
 echo -e "" >&2
 echo -e " Mandatory:" >&2
 echo -e "  -i INPUTFILE\tInput BAM file" >&2
 echo -e "  -o STRING\tOutput name">&2
}

while getopts ":h:i:p:o:" opt
do
 case "$opt" in
  h) printHelp; exit 1 ;;
  i) LOCALINPUTFILE="$OPTARG" ;;
  o) output_name="$OPTARG";;
  *) printHelp; exit 1 ;;
 esac
done

if [[ -z "$LOCALINPUTFILE" ]] ||[[ -z "$output_name"]]
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

printf "wgbs_analysis_run"
printf "${rs}"

printf "${rs}sample_id${fs}%s" "${WGBS_INTERNAL_ID}"
printf "${rs}wgbs_out_postprocessed_bam_file${fs}%s" "$LOCALINPUTFILE"
printf "${rs}conversion_rate${fs}%s" ""
printf "${rs}"

samtools view -u -F1280 $LOCALINPUTFILE | samtools mpileup -d 100000 - |awk -vOFS=$fs -vORS=$rs '{c+=1; a+= ($4-a)/c} END{printf "%savg_genome_cov%s%s" ,ORS,OFS,a}' 
printf "${rs}"
echo "LOGG ($name): `date` DONE" >&2

exit $exitSum

