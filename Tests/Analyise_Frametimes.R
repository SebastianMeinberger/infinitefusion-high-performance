#!/usr/bin/env Rscript

#library("optparse")
library("purrr")

dir <- 'Timestamped_Measurments_og_exe_fix_graphics'

loadtime <- read.csv(paste(dir, 'loadtime', sep= '/'), header = FALSE)
loadtime <- loadtime[1,1]
#parser <- OptionParser(formatter = IndentedHelpFormatter)
frametimes <- read.csv(paste(dir, 'frametime_(ms)', sep= '/'), header = FALSE)

# Filter out data from before loading completed
frametimes <- frametimes[30:nrow(frametimes),]

fps <- unlist(map(frametimes$V2, \(x) 1000/x))
find_interval <- function(list, mid, range){
	list[list$V1>(mid - range) & list$V1<(mid + range),]
}
one_sec_avg_frametime <- unlist(map(frametimes$V1,\(x) mean(find_interval(frametimes, x, 0.5)$V2)))
one_sec_avg_fps <- unlist(map(one_sec_avg_frametime, \(x) 1000/x))


data <- data.frame(timestamp=frametimes$V1,frametimes=frametimes$V2,fps=fps, Avg_frametime=one_sec_avg_frametime, Avg_fps=one_sec_avg_fps, loadtime=loadtime)
print(summary(data[,2:5]))
