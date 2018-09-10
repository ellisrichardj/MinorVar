# Rscript code.r filename 20 60

args <- commandArgs(trailingOnly = TRUE)

data = read.csv(args[1],header=TRUE)
print(paste("Plotting file ",args[1]," with parameters ",args[2]," and ",args[3],sep="")) 

seqs=unique(as.vector(data$seq))

tickes <- NULL
for(seq in seqs){
	dataSeq=data[which(data$seq==seq),]
	tickes <- c(tickes,median(as.numeric(rownames(dataSeq))))
}

jpeg(filename = paste(substr(args[1],1,nchar(args[1])-3),"jpeg",sep=""), width =1000, height = 400,quality=100,units = "px", pointsize = 14, bg="white",res = NA) 

datatoplotFirst = data[which(data$First>0 & data$First<1),]
plot(as.numeric(rownames(datatoplotFirst)),datatoplotFirst$First,pch=20,ylim=c(-0.01,1.05),xlab="Position in the genome showing variation",ylab="Proportion of each nucleotide",main=paste("Proportion for each base at each site showing variation, base calling quality > ",args[2],", mapping quality > ",args[3],sep=""),xaxt='n')



data0 <- data[which(is.element(data$pos,c(1,1000,5000,10000,15000,20000,25000,30000))),]
tickes0 <- rownames(data0) 
labs0 <- data0$pos
axis(side = 1, at = tickes0, labels= labs0)

vlines <- rownames(data[which(data$pos==1),])
for(vline in vlines) abline(v=vline,col="blue",lty=2)

datatoplotSecond = data[which(data$Second>0),]
points(as.numeric(rownames(datatoplotSecond)),datatoplotSecond$Second,col="red",pch=20)
datatoplotThird = data[which(data$Third>0),]
points(as.numeric(rownames(datatoplotThird)),datatoplotThird$Third,col="blue",pch=20)
datatoplotFour = data[which(data$Four>0),]
points(as.numeric(rownames(datatoplotFour)),datatoplotFour$Four,col="green",pch=20)

for(i in 1:length(seqs)) text(tickes[i],1.08,strsplit(seqs[i],"105")[[1]][2]) 

par(xpd=TRUE)
#par(mar = c(10,4,4,1500), xpd=TRUE)
legend(max(as.numeric(rownames(data)))-2500,0.7, pch=20,c("First call","Second call","Third call","Fourth call"), col=c("black","red","blue","green"))



dev.off()
