name=generateMetadata.sh

printHelp() {
 echo -e "Usage: `basename $0`" >&2
 echo -e "" >&2
 echo -e " Mandatory:" >&2
 echo -e "  -t FOLDER\tTemporary folder. This should be the one in which the analysis was made... That is NOT the same as the output folder" >&2
 echo -e "  -p FILE\tParameterfile" >&2
}

while getopts ":h:t:p:" opt
do
 case "$opt" in
  h) printHelp; exit 1 ;;
  t) TMPWD="$OPTARG" ;;
  p) PARAMETERFILE="$OPTARG" ;;
  *) printHelp; exit 1 ;;
 esac
done

if [[ -z "$TMPWD" ]] || [[ -z "$PARAMETERFILE" ]]
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

printf "${rs}wgbs_out_filtered_snps_vcf_file${fs}%s" "$OUTFOLDER/$OUTNAME.snp.filtered.vcf.gz"
printf "${rs}wgbs_out_filtered_cytocines_vcf_file${fs}%s" "$OUTFOLDER/$OUTNAME.cpg.filtered.vcf.gz"

printf "${rs}num_SNPs${fs}%s" `zcat $OUTFOLDER/$OUTNAME.snp.filtered.vcf.gz | grep -v "^#" |cut -f 1,2|sort -u |wc -l`
exitSum=$(( $exitSum + $? ))

zcat $OUTFOLDER/$OUTNAME.cpg.filtered.vcf.gz | $java -Xmx12G -jar $JARS/fastaUtils.jar cContext ${REFERENCE} - CG,1 CA,1 CC,1 CT,1 CH,1 CAG,1 CHH,1 CHG,1 GC,2 GCH,2 GCG,2 HCG,2 HCH,2 HCA,2 HCC,2 HCT,2 |awk -vOFS=$fs -vORS=$rs 'NR>1 {printf "%smean_meth_%s%s%s",ORS,tolower($1),OFS,$3+0}'
exitSum=$(( $exitSum + $? ))

printf "${rs}"

echo "LOGG ($name): `date` DONE" >&2

exit $exitSum

