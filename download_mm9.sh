#!/bin/bash
mkdir -p bigWig_mm9
wget http://hgdownload.soe.ucsc.edu/goldenPath/mm9/encodeDCC/wgEncodeFsuRepliChip/files.txt
for item in `grep bigWig files.txt  | cut -f 1 | grep Rep1`; do wget http://hgdownload.soe.ucsc.edu/goldenPath/mm9/encodeDCC/wgEncodeFsuRepliChip/${item} -O bigWig_mm9/${item}; done
rm files.txt
