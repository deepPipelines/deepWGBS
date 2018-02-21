#!/usr/bin/env bash

name=genMetaVcf.sh

printHelp() {
 echo -e "Usage: `basename $0`" >&2
 echo -e "" >&2
 echo -e " Mandatory:" >&2
 echo -e " -r FILE\tReference file">&2
 echo -e " -s FILE\tSNP vcf file">&2
 echo -e " -c FILE\tCPG vcf file">&2
}

while getopts ":h:r:s:g:" opt
do
 case "$opt" in
  h) printHelp; exit 1 ;;
  r) REFERENCE="$OPTARG";;
  s) SNP="$OPTARG";;
  g) CPG="$OPTARG";;
  *) printHelp; exit 1 ;;
 esac
done

if [[ -z "$REFERENCE"]]||[[ -z "$SNP"]]||[[ -z "$CPG"]]
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

printf "${rs}wgbs_out_filtered_snps_vcf_file${fs}%s" "$SNP"
printf "${rs}wgbs_out_filtered_cytocines_vcf_file${fs}%s" "$CPG"

printf "${rs}num_SNPs${fs}%s" `zcat $SNP | grep -v "^#" |cut -f 1,2|sort -u |wc -l`
exitSum=$(( $exitSum + $? ))

zcat $CPG | java -Xmx12G -jar $JARS/fastaUtils.jar cContext ${REFERENCE} - CG,1 CA,1 CC,1 CT,1 CH,1 CAG,1 CHH,1 CHG,1 GC,2 GCH,2 GCG,2 HCG,2 HCH,2 HCA,2 HCC,2 HCT,2 |awk -vOFS=$fs -vORS=$rs 'NR>1 {printf "%smean_meth_%s%s%s",ORS,tolower($1),OFS,$3+0}'
exitSum=$(( $exitSum + $? ))

printf "${rs}"

echo "LOGG ($name): `date` DONE" >&2

exit $exitSum

