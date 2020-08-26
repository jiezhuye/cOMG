# cOMG (chaotic Omics - the MetaGenomics)

This pipeline is built to ease my pressure for Multiple omics analysis. In this version, I'm focused on the process of data polishing of metagenome-wide analysis.

 

# Install

 

```

cd /path/to/your/dir/

clone git@biogit.cn:Fangchao/Omics_pipeline.git

ln -s /path/to/your/dir/cOMG/cOMG ~/bin/

# Or added to PATH

export PATH="/path/to/your/dir/cOMG":$PATH

```

 

# Usage:


```

cOMG

usage:

​    cOMG <pe|se|config|cmd> [options]

mode

​    pe|se      pair end | single end

​    config      generate a config file template

​    cmd    directely call a sub-script under bin/ or util/

options:

​    -p|path     :[essential]sample path file (SampleID|fqID|fqPath)

​    -i|ins     :[essential for pe mode]insert info file or a number of insert size

​    -s|step     :functions,default 1234

​               1    trim+filter, OA method

​               2    remove host genomic reads

​               3    soap mapping to microbiotic genomics

​               4    combine samples' abun into a single profile table

​    -o|outdir    :output directory path. Conatins the results and scripts.

​    -c|config    :provide a configure file including needed database and parameters for each setp

​    -h|help     :show help info

​    -v|version   :show version and author info.

```

 

**path file**: Record the information of the sample ID and path of raw data, including 3 columns: **Sample ID**, **Library ID** and **path of the raw data in fastq format**。

 

- `Sample ID`：Participant ID.

 

 > :warning: The relative abundance of samples with same sample ID will be calculated by combination;

 >

 > :warning: In **pe** mood, the \*1.fq and \*2.fq from the same sample should named by the same sample ID;

 >

 > :warning: Sample ID should not begin with an number.

 

- `Library ID`：The sample with multiple sequencing data should be identified with Library ID.

 

 > :warning: Sample ID can not begin with an number.

 

- `path`: The path of your fastq file

 

 > :warning: Please order by read1, read2, single read (optional)

 

e.g:

 

```

column -t test.5samples.path

t01    ERR260132 ./fastq/ERR260132_1.fastq.gz

t01    ERR260132 ./fastq/ERR260132_2.fastq.gz

t02.sth  ERR260133 ./fastq/ERR260133_1.fastq.gz

t02.sth  ERR260133 ./fastq/ERR260133_2.fastq.gz

t03_rep  ERR260134 ./fastq/ERR260134_1.fastq.gz

t03_rep  ERR260134 ./fastq/ERR260134_2.fastq.gz

t04_rep_2 ERR260135 ./fastq/ERR260135_1.fastq.gz

t04_rep_2 ERR260135 ./fastq/ERR260135_2.fastq.gz

t05    ERR260136 ./fastq/ERR260136_1.fastq.gz

t05    ERR260136 ./fastq/ERR260136_2.fastq.gz

```

 

 

 

**config file**: the parameters in each step are specified uniformly in the configuration file：

 

```

###### configuration

 

### Database location

db_host = $META_DB/human/hg19/Hg19.fa.index #The prefix of host genome db , used for removing host-source reads

db_meta = $META_DB/1267sample_ICG_db/4Group_uniqGene.div_1.fa.index,$META_DB/1267sample_ICG_db/4Group_uniqGene.div_2.fa.index #The prefix of reference database, multiple database should seperated by comma

 

### reference gene length file

RGL = $META_DB/IGC.annotation/IGC_9.9M_update.fa.len # The length of reference database, used for relative abundance calculation

### pipeline parameters

PhQ = 33           # reads Phred Quality system: 33 or 64.

mLen= 30        # minimal read length allowance

seedOA=0.9          # the cutoff for accuracy of OA seed in OA mood [0,1]

fragOA=0.8            # in OA mood, the cutoff for accuracy of full-length in OA mood [0,1]

 

qsub = 1234       #Following argment will enable only if qusb=on, otherwise you could commit it

q  = st.q       #queue for qsub

P  = st_ms       #Project id for qsub

B  = 1               #the number of submit jobs (Global)

B1 = 3               #the number of submit jobs (Step1)

p  = 6         #CPU numbers (Global)

p1 = 1               #CPU numbers (Step1)

p4 = 1               #CPU numbers (Step4)

f1 = 0.5G       #virtual free for qsub in step 1 (trim & filter)

f2 = 6G        #virtual free for qsub in step 2 (remove host genes)

f3 = 14G        #virtual free for qsub in step 3 (align to gene set)

f4 = 8G        #virtual free for qsub in step 4 (calculate soap2 aligments to abundance)

s  = 120             #interval for qusbM checking (s)

r  = 10        #repeat time when job failed or interrupted

```

 

After completed the previous config file, run the commands below can creat the working directory：

 

```

cd t

cOMG se -p demo.input.lst -c demo.cfg -o demo.test

```

 

Change directory into the working directory and make sure the script correct, then choose one mood below that suits your machine to run：

 

```

sh RUN.batch.sh         # mood 1, process the next step only when all samples’ previouse step are finished；

sh RUN.linear.1234.sh # mood2, each sample process independently；

sh RUN.qsubM.sh        # mood3, the same with mood2, using an updated qsub command to manage the script (recommend)

```

 

After programs are all finished, a stat report can be output by executing `sh report.stat.sh`
