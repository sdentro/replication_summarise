stepsize = 15000

args = commandArgs(T)
# Window in which the summarise the signal
stepsize = as.numeric(args[1]) 
inputdir = args[2]
outfile = args[3]
organism = args[4]
num_cores = as.numeric(args[5])

if (organism=="human") {
	chroms = paste0("chr", c(1:22, "X", "Y"))
} else {
	chroms = paste0("chr", c(1:19, "X", "Y"))
}


library(GenomicRanges)
library(parallel)

output = data.frame()
infiles = list.files(inputdir, pattern=".wig", full.names=T)
infiles = infiles[!grepl("unmapped", infiles)]
print(infiles)
dat = lapply(infiles, read.table, header=F, stringsAsFactors=F)
dat = lapply(dat, function(x) { x[x[,1] %in% chroms,] })

summarise_chromosome = function(dat, chr, stepsize) {
	print(chr)
	len = max(dat[[1]]$V3[dat[[1]]$V1==chr])
	intervals = data.frame(chromosome=chr, start=seq(1, (len-stepsize), stepsize), end=seq(stepsize, len, stepsize))
	intervals_gr = makeGRangesFromDataFrame(intervals)
	for (i in 1:length(dat)) {
		print(i)
		overlap = findOverlaps(intervals_gr, makeGRangesFromDataFrame(dat[[i]], seqnames="V1", start.field="V2", end.field="V3", keep.extra.columns=T))
		intervals[,paste0("sample", i)] = NA
		for (index in unique(queryHits(overlap))) {
			intervals[index,paste0("sample", i)] = mean(dat[[i]]$V4[subjectHits(overlap)[queryHits(overlap)==index]])
		}
	}
	return(intervals)
}

res = mclapply(unique(dat[[1]]$V1), summarise_chromosome, dat=dat, stepsize=stepsize, mc.cores=num_cores)
output = do.call(rbind, res)

output$average = rowMeans(output[,grepl("sample", colnames(output))], na.rm=T)
output$average[is.nan(output$average)] = NA
output$start <-format(output$start, scientific = FALSE)
output$end <-format(output$end, scientific = FALSE)
write.table(output, file=outfile, quote=F, sep="\t", row.names=F)

