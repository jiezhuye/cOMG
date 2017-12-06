# Introduction

### What do I wanna perform?

As a pipeline, I plan to orgainze the workshop directory like this:

```
./                 #output directory
|-- pip.work.sh		# A script contained all function set to run. A	MAIN SWITCH.
|-- Shell			# A directory contains all of scripts organized under steps order.
|-- Results			# A directory contains all of the results (exactly, including the intermediate results)
```

And all the users need to do is preparing a config file and write them into a script to build the workshop above.
Here is an example:

 `/ifs1/ST_MD/PMO/F13ZOOYJSY1389_T2D_MultiOmics/Users/fangchao/lipidomics.20151118/pip.config.sh`

For a better understanding of the pipeline's logic, a tree following shows you how the pip.work.sh works:

```
./pip.work.sh
	|--> sh step1.sh
			|--> sh function1.sh
					|--> sh/perl sub-function scripts/software/program [parameters]
			|--> sh function2.sh
					|--> sh/perl sub-function scripts/software/program [parameters]
			...
```

As you can see, the sub-funtion tools could come from websites, packages, or just wirtten by yourself. And what you need to do is to locate the scripts pathway and make sure the parameters are friendly for most of the naming manners, such as the capablility to read and locate an absolute path. Thus you can leave the rest things to the pipeline.

In the following step, I'll add your scripts into pipeline and distribute the unified input parameters as well as a proper output directory. Or some addtional options for the function of your part.

# Usage

This workflow beased on the dataset produced by Waters and polishing via metaX (https://www.bioconductor.org/packages/release/bioc/html/metaX.html). 

Here we started our pipeline with the input data after processed with metaX.

# Demo 

Demo case include positive and negative ion mode feature table with the head 100 lines for a quick viewing of our pipeline.

## Initializion

First let us initialize the workshop:

```shell
cd example && sh init.sh
```

init.sh will make a **project** folder which contained a excutive script and results directories for our analysis.

## RUN

```shell
cd project && sh RUN.demo.sh
```

This command will produce their results in each directory:

## *Data pretreatment*

```
00.data/DemoAnalyst.comm.phenotype.tab
```

contains the phenotype with samples involved for further analysis. Those outliers either in positive or negtive ion mode will be discarded.

```
00.data/DemoAnalyst_pos.pretreatment.res.comm.xls
```

Positive ion features' intensity with sample keeped in both ion modes.

```
00.data/DemoAnalyst_neg.pretreatment.res.comm.xls
```

Negative ion features' intensity with samples keeped in both ion modes.

##*Profile scaling*

```
01.scaled_profile/DemoAnalyst_neg.pretreatment.res.comm.range_scaling.xls
01.scaled_profile/DemoAnalyst_pos.pretreatment.res.comm.range_scaling.xls
```

Positive and negative ion features' scaled intensity separately.

***Note***: *Following analysis will based on the scaled intensity profile and phenotype.*

## *Rank-sum test*

```
02.wilcox/DemoAnalyst_neg.Diagnosis-2.NGT-vs-Pre-DM-vs-T2D.adj_HT1_kw.direction.xls
02.wilcox/DemoAnalyst_neg.Diagnosis-2.NGT-vs-Pre-DM-vs-T2D.adj_NA_kw.direction.xls
02.wilcox/DemoAnalyst_pos.Diagnosis-2.NGT-vs-Pre-DM-vs-T2D.adj_HT1_kw.direction.xls
02.wilcox/DemoAnalyst_pos.Diagnosis-2.NGT-vs-Pre-DM-vs-T2D.adj_NA_kw.direction.xls
```

Depends on your configure, whether adjust or not,  Wilcoxon tests or Kruskal-Wallis Test will perfomed here.

## *PERMANOVA*##

```
03.permanova/DemoAnalyst_neg.bary_adonis.txt
03.permanova/DemoAnalyst_pos.bary_adonis.txt
```

## *RANDOMFOREST*##

```
04.randomForest/DemoAnalyst_*.batch/Repeat_*/Repeat_*_DemoAnalyst_*.Pre-DM-vs-NGT_randomForest.pdf
```

Random Forest analysis results shows here.

# Correlation and GLM 

This case we performed the selected features and phenotyp for correlation and GLM logistic analysis, as shown in our paper.

## Initializion

Initialize the workshop into the same folder(it won't overwrite the demo results) :

```shell
cd example && sh init2.sh
```

init.sh will make a **project** folder which contained a excutive script and results directories for our analysis.

## RUN

```shell
cd project && sh RUN.DEMO.sh
```

This command will produce their results in each directory:

## *Correlation*

```
05.correlation/DemoAnalyst_selected.spearman.xls.spearman.tab
```

## GLM

```
06.GLM/DemoAnalyst_selected.logist.sta
```

 







