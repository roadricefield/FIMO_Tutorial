library(tidyverse)

#ラベルからピークの位置を取り出す関数
SepRegion <- function(S){
  colon <- regexpr(":", S)[[1]]
  hyphen <- regexpr("-", S)[[1]]
  chr <- substr(S, 1, colon - 1)
  peak_start <- substr(S, colon + 1, hyphen - 1)
  peak_end <- substr(S, hyphen + 1, nchar(S))
  return(c(chr, peak_start, peak_end))
}

fimo_res <- read.table("./fimo_Foxp3_in_Treg_ATAC/fimo.txt", stringsAsFactors = F) #fimo.txtへのパスを指定

colnames(fimo_res) <- c("motif_ID", "region", "start", "end", "strand", "score",
                        "p-value", "q-value", "matched_sequence")

fimo_res$region <- gsub("::", "", fimo_res$region) #最初の::を消す

tmp <- NULL
for(i in 1:nrow(fimo_res)){
  tmp <- rbind(tmp, SepRegion(fimo_res$region[i]))
}

tmp <- as.data.frame(tmp)

colnames(tmp) <- c("chr", "peak_start", "peak_end")
tmp$chr <- tmp$chr %>% as.character()
tmp$peak_start <- tmp$peak_start %>% as.character() %>% as.numeric()
tmp$peak_end <- tmp$peak_end %>% as.character() %>% as.numeric()

fimo_res <- cbind(fimo_res, tmp)

fimo_res$motif_start <- fimo_res$peak_start + (fimo_res$start - 1)
fimo_res$motif_end <- fimo_res$peak_start + (fimo_res$end)

fimo_bed <- dplyr::select(fimo_res, one_of(c("chr", "motif_start", "motif_end")))
fimo_bed <- fimo_bed[order(fimo_bed$chr, fimo_bed$motif_start),] #ソート

write.table(fimo_bed, "Foxp3_in_Treg_ATAC.bed", row.names = F, col.names = F, quote = F, sep = "\t")
