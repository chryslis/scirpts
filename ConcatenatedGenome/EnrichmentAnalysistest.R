library(data.table)
library(ggplot2)
library(bigmemory)
library(gplots)
library(heatmap3)
library(lattice)
library(ComplexHeatmap)
library(circlize)

#memory problems
EnrichmentSubset = fread("4169.SuperFamily.Shuffle.FULL",verbose=TRUE)
EnrichmentSubset = fread("4169.SuperFamilies.ReadEnrichment.FULL",verbose=TRUE)

Header=read.table("4169.SuperFamilies.Header",stringsAsFactors = FALSE)

Reads = EnrichmentSubset[,1]
rownames(EnrichmentSubset)= Reads$V1

EnrichmentSubset = EnrichmentSubset[,-1]
colnames(EnrichmentSubset)= as.character(Header[,1:50])
rm(Header)
rm(Reads)

EnrichmentSubset = EnrichmentSubset[apply(EnrichmentSubset, 1, function(y) !all(is.na(y))),]

###Processing for Families
EnrichmentSubset[is.na(EnrichmentSubset)] = 0
colSums(EnrichmentSubset)
EnrichmentSubset = EnrichmentSubset[!rowSums(EnrichmentSubset,na.rm = TRUE)<50,]
EnrichmentSubset$`LINE?` = NULL
EnrichmentSubset$`LTR?` = NULL
EnrichmentSubset$`SINE?` = NULL
EnrichmentSubset$`Unknown?` = NULL

f1 <- function(x){ stopifnot(is.data.frame(x), ncol(x)>=1)
  rowsum <- x[[1]]
  if(ncol(x)>1) for(i in 2:ncol(x))
    rowsum <- rowsum + x[[i]]
  for(i in 1:ncol(x))
    x[[i]] <- x[[i]] / rowsum
  x
}

NormalisedSet = f1(EnrichmentSubset)

rownames(NormalisedSet) = rownames(EnrichmentSubset)

#lapply(names(NormalisedSet), function(x) assign(x, NormalisedSet[x], envir = .GlobalEnv))

Matrix = as.matrix(NormalisedSet)
Mat2 = as.matrix(EnrichmentSubset)

col1 = colorRamp2(seq(min(Matrix), max(Matrix), length = 3), c("blue", "#EEEEEE", "red"))


Heatmap(Matrix,cluster_rows = FALSE,cluster_columns = FALSE,show_row_names = FALSE)

Heatmap(Mat2,cluster_rows = FALSE,cluster_columns = FALSE,show_row_names = FALSE)

#/home/chrys/Documents/thesis/data/analysis/artificialGenome/Annotation

HeatMapForCleaned = Heatmap(Matrix,col = col1 ,cluster_rows = FALSE,cluster_columns = FALSE,show_row_names = FALSE) 

png(filename = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/Annotation/name.png")
plot(HeatMapForCleaned)
dev.off()

###Coverage per Family###

CovPerFam = read.table("4169.SuperFamily.IDCoverage.FULL.bed",sep = ",",header = TRUE)

CovPerFam = fread("4169.SuperFamily.IDCoverage.FULL.bed",verbose=TRUE)



MeanCovPerFam = as.data.frame(colMeans(CovPerFam,na.rm = TRUE))
colnames(MeanCovPerFam) = "MeanCoverage"

ReadCountPerFam = read.table("4169.IDReadCount",sep = ",", header = TRUE)
MeanReadsPerFam = as.data.frame(colMeans(ReadCountPerFam,na.rm = TRUE))
colnames(MeanReadsPerFam) = "ReadCount"

ReadCountToCoverage = ReadCountPerFam*CovPerFam


#Calculating fraktion of Reads to Coverage to normalise against low read count against high coverage

ReadsToCov = MeanReadsPerFam*MeanCovPerFam
ReadsToCov$Families = rownames(ReadsToCov)

index = which(with(ReadsToCov,(Families == "SSU.rRNA_Hsa") | (Families == "LSU.rRNA_Hsa")))

ReadsToCovCleaned = ReadsToCov[-index,]

#Only if needed
ReadsToCovCleanedSort = ReadsToCovCleaned[order(ReadsToCovCleaned$ReadCount),]

#No cleanup
ReadsToCov = ReadsToCov[order(ReadsToCov$ReadCount),]

ReadsToCov1 = ReadsToCov[1:105,]
ReadsToCov2 = ReadsToCov[106:211,]
ReadsToCov3 = ReadsToCov[212:317,]
ReadsToCov4 = ReadsToCov[318:422,]
ReadsToCov5 = ReadsToCov[422:527,]
ReadsToCov6 = ReadsToCov[528:633,]
ReadsToCov7 = ReadsToCov[739:843,]
ReadsToCov8 = ReadsToCov[844:949,]
ReadsToCov9 = ReadsToCov[950:1052,]


ggplot(ReadsToCov1 ,aes(x = reorder(Families,ReadCount,sum), y = ReadCount))+
  geom_bar(stat ="identity")+
  theme(axis.text.x=element_text(angle=90,hjust = 1))+
  labs(title = "Coverage normalised to Read Count - Lowest 100", 
       x = "ReadsToCoverage",y = "Reads/Coverage")+
theme(axis.text.x=element_text(angle=90,hjust = 1))

ggplot(ReadsToCov5 ,aes(x = reorder(Families,ReadCount,sum), y = ReadCount))+
  geom_bar(stat ="identity")+
  theme(axis.text.x=element_text(angle=90,hjust = 1))+
  labs(title = "Coverage normalised to Read Count - Middle 100 ", 
       x = "ReadsToCoverage",y = "Reads/Coverage")+
  theme(axis.text.x=element_text(angle=90,hjust = 1))

ReadsToCov9 = ReadsToCov9[-(97:101),]

ggplot(ReadsToCov9 ,aes(x = reorder(Families,ReadCount,sum), y = ReadCount))+
  geom_bar(stat ="identity")+
  theme(axis.text.x=element_text(angle=90,hjust = 1))+
  labs(title = "Coverage normalised to Read Count - Top100", 
       x = "ReadsToCoverage",y = "Reads/Coverage")+
  theme(axis.text.x=element_text(angle=90,hjust = 1))



