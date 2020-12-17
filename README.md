# FIMO を使って特定の転写因子結合モチーフを探そう！！  

このリポジトリには Qiita バイオインフォマティクスアドベントカレンダー2020 12/18 の「FIMO を使って特定の転写因子結合モチーフを探そう！！」で使用する. スクリプト等をおいてあります.  

## 1. `Treg_ATAC_processing.sh`  

fastq ファイルをダウンロードしたディレクトリと同じディレクトリにおいて実行してください.  

```
nohup bash Treg_ATAC_processing.sh > Treg_ATAC_processing.log &
```  

また, このスクリプト中の `picard CollectInsertSizeMetrics` ではインサートサイズのヒストグラムを作成します. ATAC-seq ではその原理上, ヌクレオソーム 1 巻分（約 150 b）, 2 巻分 (約 300 b), 3 巻分 (約 450 b) ... のインサートサイズのポピュレーションが段階的に現れるはずです. インサートサイズのヒストグラムがそうなっていれば ATAC-seq の実験は良好に行われただろうと判断されます.  

## 2. `Make_Foxp3_loci_bed.R`  
発見した Foxp3 の位置の BED ファイル (`Foxp3_in_Treg_ATAC.bed`) を FIMO の結果を読み込んで作成する R スクリプト.  

## 3. `Treg_ATAC_peaks.fa`  
`Treg_ATAC_processing.sh` でピークコールされた位置の DNA 配列.