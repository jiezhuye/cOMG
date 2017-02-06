# Omics_pipeline
This pipeline is to ease my pressure for Multiple omics analysis. In this version, I'm focused on the process of data polishing.

# Get Start

本项目目前仅包含**Metagenomics宏基因组学标准流程**和**Lipidomics脂质组学分析流程**。

### Metagenomics pipeline

在集群环境使用本流程，请将主程序添加到环境变量：

```
ln -s /ifs1/ST_MD/PMO/script/flow/Omics_pipeline/MetaGenomics/CHAOmics_MetaGenomics_v0.1_Init.pl ~/bin/
```

如果你所在的环境访问不了我的主程序，请在集群工作目录下`clone`本仓库并将主程序添加到环境变量中。

```
cd /your/dir/
clone git@biogit.cn:Fangchao/Omics_pipeline.git
ln -s /your/dir/Omics_pipeline/MetaGenomics/CHAOmics_MetaGenomics_v0.1_Init.pl ~/bin/
```

#### Usage:

```
CHAOmics_MetaGenomics_Init.pl #直接执行本程序可以查看使用说明
usage:
        perl /share/bin/CHAOmics_MetaGenomics_v0.1_Init.pl <pe|se> [options]
pattern
        pe|se           pair end | single end
options:
        -p|path         :[essential]sample path file (SampleID|fqID|fqPath)
        -i|ins          :[essential for pair-end seq]insert info file
        -s|step         :functions,default 1234
                             1       trim+filter
                             2       remove host genomic reads
                             3       soap mapping to microbiotic genomics
                             4       combine samples' abun into a single profile table
        -o|outdir       :output directory path. Conatins the results and scripts.
        -c|config       :provide a configure file including needed database and parameters for each setp, default below:
                             Qt  ||= 20              Qvalue for trim 
                             l   ||= 10              bp length for trim
                             N   ||= 1               tolerance number of N for filter
                             Qf  ||= 15              Qvalue for filter. The reads which more than half of the bytes lower than Qf will be discarded.
                             lf  ||= 0               left fq length. The minimum
                             q   ||= "st.q"          queue for qsub
                             P   ||= "st_ms"         Project id for qsub
                             pro ||= 8                       process number for qsub
                             vf1 ||= "0.3G"          virtual free for qsub in step 1 (trim & filter)
                             vf2 ||= "8G"            virtual free for qsub in step 2 (remove host genes)
                             vf3 ||= "16G"           virtual free for qsub in step 3 (aligned to gene set)
                             vf4 ||= "10G"           virtual free for qsub in step 4 (calculate soap results to abundance)
                             m   ||= 99              job number submitted each for qsub
                             r   ||= 1               repeat time when job failed or interrupted
        -h|help         :show help info
        -v|version      :show version and author info.
```

**path file**: 用于记录raw data文件位置和id信息的文件，每行三列分别记录下**样本编号**, **数据编号** 和 **fq文件路径**。

- `样本编号`：生物学，统计学意义上的样本个体，用于后续分析的基本个体
- `数据编号`：如果同一个样本进行多次测序，则会产生多个数据，此时需要用数据编号来区分（可以使文库号，日期，批次，等等）。`注意`:拥有相同`样本编号`的多个数据会被最终合并计算相对丰度。
- `fastq路径`: 必须是工作环境可以访问到的路径位置

上述配置文件准备完毕后，运行本脚本可以生成工作目录：

```
CHAOmics_MetaGenomics_v0.1_Init.pl se -p sample.path.file -o demo
```

随后进入工作目录，检查脚本无误后可以启动执行脚本：

```
cd demo
sh qsub_all.sh		# 模式一，选择其一即可
sh linear.1234.sh	# 模式二，选择其一即可，本模式会产生较多进程
```

完成后可以执行`sh REPORT.sh`打印报告表格。

若中途出现错误，可以进入`script`目录对个别脚本进行调试。

--------------

### Lipidomics pipeline

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

