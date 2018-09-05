# ENCODE hg19 replication timing essays based on replichip
window=$1

echo "Converting the data"
mkdir -p wig_hg19
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bigWigToWig
chmod u+x bigWigToWig
for item in `find bigWig_hg19/ | grep "\.bigWig"`; do echo ${item}; outp=`basename ${item} | cut -f 1 -d .`; bigWigToWig.pl ${item} > wig_hg19/${outp}.wig; done

echo "Summarising the data"
Rscript summarise_wigs.R ${window} wig_hg19 hg19_combined_replication_timing_${window}.txt
gzip hg19_combined_replication_timing_${window}.txt
