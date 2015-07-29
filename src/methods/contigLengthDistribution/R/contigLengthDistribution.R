# Arguments
args=commandArgs(trailingOnly = TRUE)
input=args[1]
output=args[2]
prefix=args[3]
# Format input
contigs=data.frame(read.table(input))
colnames(contigs)=c("length","counts")
contigs$counts=contigs$counts/sum(contigs$counts)
# Get maximum and minimum size
min_length=min(contigs$length)
max_length=max(contigs$length)
# Generate a grid
grid_plot_x=as.vector(seq(min_length-5,max_length+5))
grid_plot_y=as.vector(rep(0,max_length-min_length+1))
grid_plot=data.frame(cbind(grid_plot_x,grid_plot_y))
colnames(grid_plot)=c("length","counts")
# Fill the grid with the counts
grid_plot[is.element(grid_plot$length,contigs$length),2]=contigs$counts
# Generate plot
pdf(output)
plot(grid_plot$length,grid_plot$counts,type="s",main=prefix,xlab="Contig length",ylab="Density")
dev.off()
