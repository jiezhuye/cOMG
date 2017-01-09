# Omics_pipeline
This pipeline is to ease my pressure for Multiple omics analysis. In this version, I'm focused on the process of data polishing.

# Get Start

若要使用Metagenomics分析流程，请将主程序添加到环境变量：

```
ln -s /ifs1/ST_MD/PMO/script/flow/Omics_pipeline/MetaGenomics/CHAOmics_MetaGenomics_Init.dev.pl ~/bin/
```

如果你所在的环境访问不了我的主程序，请`clone`本仓库并将主程序添加到环境变量中。

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

