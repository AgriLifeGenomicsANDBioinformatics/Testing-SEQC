#!/usr/bin/env Rscript 

# Arguments
args <- commandArgs(trailingOnly = TRUE)
input=args[1]
output=args[2]

## Read in data
P_agr=read.table(input,sep="\t",header=TRUE,row.names = 1)
P_agr=P_agr[,-ncol(P_agr)]
kmers=rownames(P_agr)

## Find SSD
t_P_agr <- t(P_agr)
eigen_vectors_agr <- as.matrix(eigen(t_P_agr)$vectors)
SSD_agr <- as.matrix(as.numeric(eigen_vectors_agr[,1]))
SSD_agr <- SSD_agr / sum(SSD_agr[,1])
SSD_agr <- as.vector(t(SSD_agr))

out=cbind(kmers,SSD_agr)

# Outpu
write.table(out,file=output,col.names=F,row.names=F,sep="\t",quote=F)
