args = commandArgs(trailingOnly=TRUE)

posfile <- args[1]
gene <- args[2]

positions <- read.table(file = posfile, sep = "\t", header=F)
positions$row <- as.numeric(row.names(positions))

# CREATE BINS FOR SPECIFIC EXONIC REGIONS
rows <- nrow(positions)
bins <- apply(positions, 1, function(x){
  if(x[3] != rows){
    current_startstop <- x[2]
    next_startstop <- positions[(x[3]+1), 2]
    current_position <- x[1]
    next_position <- positions[(x[3]+1), 1]
    
    if(current_startstop <= next_startstop){
      return(data.frame(current_position, next_position))
    }
    else{
      #do nothing
    }
    
  }else{
    #do nothing
  }
  
})
df_bins <- do.call("rbind", bins)

outputfile <- paste("temp/", gene, ".countingbins.tsv", sep="")
write.table(file=outputfile, df_bins, row.names=F, col.names=F)

# CREATE REGIONS FOR MPILEUP (mpileup on bins increases computing time due to overlap in bins)
endpoints_index <- unlist(apply(positions, 1, function(x){
  if(x[3] != rows){
    current_startstop <- x[2]
    next_startstop <- positions[(x[3]+1), 2]
    
    if(current_startstop > next_startstop){
      return(x[3])
      
    }
  }
}))
startpoints_index <- endpoints_index + 1
startpoints_index <- append(1, startpoints_index)
endpoints_index <- append(endpoints_index, rows)

endpoints <- unlist(lapply(endpoints_index, function(x){
  positions$V1[x]
}))
startpoints <- unlist(lapply(startpoints_index, function(x){
  positions$V1[x]
}))

df_regions <- data.frame(startpoints, endpoints)

outputfile2 <- paste("temp/", gene, ".mpileupregions.tsv", sep="")
write.table(file=outputfile2, df_regions, row.names=F, col.names=F)
