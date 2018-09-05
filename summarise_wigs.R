stepsize = 15000

args = commandArgs(T)
# Window in which the summarise the signal
stepsize = as.numeric(args[1]) 
inputdir = args[2]
outfile = args[3]


library(GenomicRanges)
output = data.frame()
infiles = list.files(inputdir, pattern=".wig", full.names=T)
infiles = infiles[!grepl("unmapped", infiles)]
print(infiles)
dat = lapply(infiles, read.table, header=F, stringsAsFactors=F)
for (chr in unique(dat[[1]]$V1)) {
	print(chr)
	len = max(dat[[1]]$V3[dat[[1]]$V1==chr])
	intervals = data.frame(chromosome=chr, start=seq(1, (len-stepsize), stepsize), end=seq(stepsize, len, stepsize))
	for (i in 1:length(dat)) {
		print(i)
		overlap = findOverlaps(makeGRangesFromDataFrame(intervals), makeGRangesFromDataFrame(dat[[i]], seqnames="V1", start.field="V2", end.field="V3", keep.extra.columns=T))
		intervals[,paste0("sample", i)] = NA
		for (index in unique(queryHits(overlap))) {
			intervals[index,paste0("sample", i)] = mean(dat[[i]]$V4[subjectHits(overlap)[queryHits(overlap)==index]])
		}
	}
	output = rbind(output, intervals)
}
output$average = rowMeans(output[,grepl("sample", colnames(output))], na.rm=T)
output$average[is.nan(output$average)] = NA
output$start <-format(output$start, scientific = FALSE)
output$end <-format(output$end, scientific = FALSE)
write.table(output, file=outfile, quote=F, sep="\t", row.names=F)

