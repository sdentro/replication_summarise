# ENCODE mm9 replication timing essays based on replichip

# liftover file from http://hgdownload-test.cse.ucsc.edu/goldenPath/mm9/liftOver/mm9ToMm10.over.chain.gz
window=$1

chainfile="mm9ToMm10.over.chain.gz"

echo "Converting the data"
mkdir -p wig_mm9 wig_mm10
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bigWigToWig
chmod u+x bigWigToWig
for item in `find bigWig_mm9/ | grep "\.bigWig"`; do echo ${item}; outp=`basename ${item} | cut -f 1 -d .`; bigWigToWig.pl ${item} > wig_mm9/${outp}.wig; done

echo "Lifting over mm9 to mm10"
wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/liftOver
chmod u+x liftOver
for item in `ls wig_mm9/`; do ./liftOver wig_mm9/${item} ${chainfile} wig_mm10/${item} wig_mm10/${item}_unmapped.txt; done

echo "Summarising the data"
Rscript summarise_wigs.R ${window} wig_mm10 mm10_combined_replication_timing_${window}.txt
gzip mm10_combined_replication_timing_${window}.txt
