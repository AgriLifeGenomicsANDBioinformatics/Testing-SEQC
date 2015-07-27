args <- commandArgs(trailingOnly = TRUE)

# Read in all the matrices
nfiles=length(args)-1
for(i in 1:nfiles){
    if(i==1){
        sum=read.table(args[i])
    } else {
        sum=sum+read.table(args[i])
    }
}   

# Output
write.table(sum,file=args[length(args)],sep="\t",quote=FALSE)
