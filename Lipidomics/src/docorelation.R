## docorelation ##

args <- commandArgs(T)
	if (length(args) != 3){
		stop("Rscript docorelation.R [phenotype.table] [profile.table] [prefix]")
	}

phe.f <- args[1]
pro.f <- args[2]
pfx.c <- args[3]

phe.t <- as.matrix(read.table(phe.f, row.names=1, header = TRUE,sep="\t"))
pro.t <- as.matrix(read.table(pro.f, row.names=1, header = TRUE,sep="\t"))

	phe.n <- length(colnames(phe.t))
pro.n <- length(rownames(pro.t))

	out.s <- matrix("NA",pro.n,phe.n*2)
rownames(out.s) <- rownames(pro.t)
	colnames(out.s) <- rep("estimate",phe.n*2)

	out.k <- matrix("NA",pro.n,phe.n)
rownames(out.k) <- rownames(pro.t)
	colnames(out.k) <- rep("estimate",phe.n)
library(pcaPP)

	for (i in 1:phe.n){
		x <- phe.t[,i] 
			x <-as.numeric( as.factor(phe.t[,i] ))
			colnames(out.s)[i*2-1] <- colnames(phe.t)[i]
			colnames(out.k)[i] <- colnames(phe.t)[i]
			for (j in 1:pro.n){
				y <- pro.t[j,]
					id <- !is.na(x) & !is.na(y)
					cor.s <- cor.test(x,y,method="s")
					out.s[j,(i*2-1):(i*2)] <- c(cor.s$p.value, cor.s$estimate)
									 out.k[j,i] <- cor.fk(x[id],y[id])
			}
	}

#output
write.table(out.s, file=paste(pfx.c,"spearman.tab",sep="."), quote = FALSE, sep = "\t", col.names = TRUE, row.names = TRUE)
write.table(out.k, file=paste(pfx.c,"kendall.csv", sep="."), quote = FALSE, sep = "\t", col.names = TRUE, row.names = TRUE)

