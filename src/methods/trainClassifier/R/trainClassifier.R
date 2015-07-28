args <- commandArgs(trailingOnly = TRUE)

# Load seqinr library to deal with fasta format
library(seqinr)

# Read in fasta file
fasta<-read.fasta(args[1])

# Convert it to data.frame
for(i in 1:length(fasta)){
    new_sample<-data.frame(unlist(fasta[i]),stringsAsFactors=FALSE)
    colnames(new_sample)<-names(fasta)[i]
    rownames(new_sample)<-seq(1,nrow(new_sample))
    if(i==1){
        all_samples<-new_sample
    } else {
        all_samples<-cbind(all_samples,new_sample)
    }
}

# Code the nucleotides
# Need to think of a way to not bias the classifier
# E.g. a C instead of an A is less penalyzed than a G.
# Maybe it would be a good idea to implement something like the
# penalty matrices in the alignments.
all_samples<-replace(all_samples,all_samples=="-",0)
all_samples<-replace(all_samples,all_samples=="a",1)
all_samples<-replace(all_samples,all_samples=="c",2)
all_samples<-replace(all_samples,all_samples=="u",3)
all_samples<-replace(all_samples,all_samples=="g",4)

