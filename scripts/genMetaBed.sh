name=generateMetadata.sh

printHelp() {
 echo -e "Usage: `basename $0`" >&2
 echo -e "" >&2
 echo -e " Mandatory:" >&2
 echo -e "  -t FOLDER\tTemporary folder. This should be the one in which the analysis was made... That is NOT the same as the output folder" >&2
 echo -e "  -p FILE\tParameterfile" >&2
 echo -e "  -c FILE\tCpG Islands file" >&2
}

while getopts ":h:t:p:c:" opt
do
 case "$opt" in
  h) printHelp; exit 1 ;;
  t) TMPWD="$OPTARG" ;;
  p) PARAMETERFILE="$OPTARG" ;;
  c) CPG_ISLANDS="$OPTARG";;
  *) printHelp; exit 1 ;;
 esac
done

if [[ -z "$TMPWD" ]] || [[ -z "$PARAMETERFILE" ]]||[[ -z "$CPG_ISLANDS"]]
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

bedFile=`ls $OUTFOLDER/$OUTNAME.cpg.filtered.CG.bed.gz|head -1`

printf "${rs}wgbs_out_filtered_cpg_bed_file${fs}%s" "$bedFile"

if [[ "$bedFile" == *.CG.bed.gz ]]
then
 #WGBS CG
 join -1 1 -2 1 -a 1 -a 2 <(zcat $bedFile |awk '$6=="+" {print $1"_"$2,$6,$1,$2,$4,$5}' |sort -k1,1) <(zcat $bedFile |awk '$6=="-" {print $1"_"($2-1),$6,$1,$2-1,$4,$5}' |sort -k1,1) |awk -vOFS='\t' 'NF==11 {print $3,$4,$5,$6,$10,$11;next} $2=="-" {print $3,$4,"NA",0,$5,$6;next} {print $3,$4,$5,$6,"NA",0}' > $TMPWD/$OUTNAME.paired.data.csv
 exitSum=$(( $exitSum + $? ))
elif [[ "$bedFile" == *.GCH.bed.gz ]]
then
 #NOMe GCH
  join -1 1 -2 1 -a 1 -a 2 <(zcat $bedFile |awk '$6=="+" {print $1"_"($2-1),$6,$1,$2-1,$4,$5}' |sort -k1,1) <(zcat $bedFile |awk '$6=="-" {print $1"_"$2,$6,$1,$2,$4,$5}' |sort -k1,1) |awk -vOFS='\t' 'NF==11 {print $3,$4,$5,$6,$10,$11;next} $2=="-" {print $3,$4,"NA",0,$5,$6;next} {print $3,$4,$5,$6,"NA",0}' > $TMPWD/$OUTNAME.paired.data.csv
 exitSum=$(( $exitSum + $? ))
else
 touch $TMPWD/$OUTNAME.paired.data.csv
fi

awk '{print $4+$6}' $TMPWD/$OUTNAME.paired.data.csv |sort -g |awk -vOFS=$fs -vORS=$rs -vLINENR=`cat $TMPWD/$OUTNAME.paired.data.csv |wc  -l` 'BEGIN {c25=int(0.25*LINENR);c50=int(0.5*LINENR);c75=int(0.75*LINENR)} NR==c25 {v25=$1} NR==c50 {v50=$1} NR==c75 {v75=$1} {c+=1;s+=$1} END{printf "%scpg_cov_25%s%s%scpg_cov_50%s%s%scpg_cov_75%s%s%scpg_cov_mean%s%s",ORS,OFS,v25,ORS,OFS,v50,ORS,OFS,v75,ORS,OFS,s/c}'
exitSum=$(( $exitSum + $? ))

printf "${rs}num_called_cpgs${fs}%s" `zcat $bedFile |tail -n +2 |wc -l`
exitSum=$(( $exitSum + $? ))

awk -vOFS=$fs -vORS=$rs '$4>0 && $6>0 {b++;next} {s++} END{printf "%snrcpg_both%s%s%snrcpg_single%s%s",ORS,OFS,b,ORS,OFS,s}' $TMPWD/$OUTNAME.paired.data.csv
exitSum=$(( $exitSum + $? ))

cut -f 1 $TMPWD/$OUTNAME.paired.data.csv |sort |uniq -c |awk -vOFS=$fs -vORS=$rs 'NR==1 {count=$1;chr=$2;next} {count=count","$1;chr=chr","$2} END {printf "%snr_cpgSplit_count%s%s%snr_cpgSplit_chr%s%s",ORS,OFS,count,ORS,OFS,chr}'
exitSum=$(( $exitSum + $? ))

awk -vOFS='\t' '{print $1,$2,$2+2,$4+$6}' $TMPWD/$OUTNAME.paired.data.csv |bedtools intersect -u -a - -b ${CPG_ISLANDS} |awk -vOFS=$fs -vORS=$rs '{s+=$4;c+=1} END{printf "%scpg_island_cov_mean%s%s",ORS,OFS,s/c}'
exitSum=$(( $exitSum + $? ))

printf "${rs}strandbias_meth${fs}%s"
awk '$0!~/NA/ {print $3"\t"$5}' $TMPWD/$OUTNAME.paired.data.csv | Rscript correlation.r out.cpg.filtered.strandBias.meth.png
exitSum=$(( $exitSum + $? ))
printf "${rs}strandbias_cov${fs}%s"
awk '$0!~/NA/ {print $4"\t"$6}' $TMPWD/$OUTNAME.paired.data.csv | Rscript correlation.r out.cpg.filtered.strandBias.cov.png
exitSum=$(( $exitSum + $? ))

printf "${rs}"
echo "LOGG ($name): `date` DONE" >&2

exit $exitSum

