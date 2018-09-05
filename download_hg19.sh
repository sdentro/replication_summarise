#!/bin/bash
mkdir -p bigWig_hg19
wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeFsuRepliChip/files.txt
for item in `grep bigWig files.txt  | cut -f 1 | grep Rep1`; do wget http://hgdownload.soe.ucsc.edu/goldenPath/hg19/encodeDCC/wgEncodeFsuRepliChip/${item} -O bigWig_hg19/${item}; done
rm files.txt
