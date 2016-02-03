#!/usr/bin/perl -w
use warnings;
use strict;
use Getopt::Long;
use File::Basename;
use FindBin qw($Bin);
use Cwd 'abs_path';

my $cwd = abs_path;
#my($f,$f_ins,$s,$out_dir) = @ARGV;
#my $usage = "usage: perl $0 <path_file> <ins_file> <steps(1234)> <output dir>
#	path_file should contained such column:
	#sample_name\t#trim_quality\t#trim_length_cut\t#N_cutoff\t#50\%ofQ_control\t#path
	#sample1\t20\t10\t1\t15\t/path/to/fq/file
#";
sub usage {
	print <<USAGE;
usage:
	perl $0 <pe|se> [options]
pattern
	pe|se		pair end | single end
options:
	-p|path		:[essential]sample path file
	-i|ins		:[essential]insert info file
	-s|step		:functions,default 1234
					1	trim+filter
					2	remove host genomic reads
					3	soap mapping to microbiotic genomics
					4	combine samples' abun into a single profile table
	-o|outdir	:output directory path. Conatins the results and scripts.
	-c|config	:set parameters for each setp, default Qt=20,l=10,N=1,Qf=15,lf=0
					Qt	Qvalue for trim
					l	bp length for trim
					N	tolerance number of N for filter
					Qf	Qvalue for filter. The reads which more than half of the bytes lower than Qf will be discarded.
	-h|help		:show help info
	-v|version	:show version and author info.
USAGE
};
my($path_f,$ins_f,$step,$out_dir,$config,%CFG,$help,$version);
GetOptions(
	"p|path:s"    => \$path_f,
	"i|ins:s"     => \$ins_f,
	"s|step:i"    => \$step,
	"o|outdir:s"  => \$out_dir,
	"c|config:s"  => \$config,
	"h|help:s"    => \$help,
	"v|version:s" => \$version,
);
my $pattern = $ARGV[0];
die &usage if ( (!defined $path_f)||(defined $help) );
die &version if defined $version;

# ####################
# initialize variables
# ####################
$step    ||= "1234";
$out_dir ||= $cwd; $out_dir = abs_path($out_dir);
$path_f = abs_path($path_f);
$ins_f = "SE" if $pattern =~ /se/i;
$ins_f  = abs_path($ins_f) if $ins_f ne "SE";
$config  ||= "Qt=20,l=10,N=1,Qf=15,lf=0";
foreach my $par (split(/,/,$config)){
	my @a = split(/=/,$par);
	$CFG{$a[0]} = $a[1];
}

# scripts under bin
my $bin = "$Bin/bin";
#my $s_trim   = "$bin/trimReads.pl";
#my $s_filter = "$bin/filterReads.pl";
my $s_clean  = "$bin/readsCleaning.pl";
my $s_rm     = "/ifs5/PC_MICRO_META/PRJ/MetaSystem/analysis_flow/bin/program/rmhost_v1.0.pl";
my $s_soap   = "$bin/soap2BuildAbundance.dev.pl";
my $s_abun   = "$bin/BuildAbundance.dev.pl";
# public database prefix
my $s_db     = "/nas/RD_09C/resequencing/resequencing/tmp/pub/Genome/Human/human.fa.index";
# project results directiory structure
my $dir_s = $out_dir."/script";
	my $dir_sI = $dir_s."/individual";
	my $dir_sS = $dir_s."/samples";
	my $dir_sB = $dir_s."/steps";
#my $dir_t = $out_dir."/trim";
#my $dir_f = $out_dir."/filter";
my $dir_c = $out_dir."/clean";
my $dir_r = $out_dir."/rmhost";
my $dir_sp = $out_dir."/soap";

system "mkdir -p $dir_s" unless(-d $dir_s);
	system "mkdir -p $dir_sI" unless(-d $dir_sI);
	system "mkdir -p $dir_sS" unless(-d $dir_sS);
	system "mkdir -p $dir_sB" unless(-d $dir_sB);
#system "mkdir -p $dir_f" unless(-d $dir_f or $s !~ /1/);
#system "mkdir -p $dir_t" unless(-d $dir_t or $s !~ /2/);
system "mkdir -p $dir_c" unless(-d $dir_c or $step !~ /1/);
system "mkdir -p $dir_r" unless(-d $dir_r or $step !~ /2/);
system "mkdir -p $dir_sp" unless(-d $dir_sp or $step !~ /3/);

open IN,"<$path_f" || die $!;
my (%SAM,@samples,$tmp_out,$tmp_outN,$tmp_outQ);
while (<IN>){
	chomp;
	my @a = split;
	my ($sam,$pfx,$path) = @a;
	$SAM{$sam}{$pfx} = $path;
}
###############################
$CFG{'q'}  ||= "st.q";
$CFG{'P'}  ||= "st_ms";
$CFG{'pro'}  ||= 8;
$CFG{'vf1'} ||= "0.3G";
$CFG{'vf2'} ||= "8G";
$CFG{'vf3'} ||= "15G";
$CFG{'vf4'} ||= "10G";
$CFG{'m'} ||= 30;

## start <- top exec batch scripts
open C1,">$out_dir/qsub_all.sh";
print C1 "perl /home/fangchao/bin/qsub_all.pl -N B.c -d $dir_s/qsub_1 -l vf=$CFG{'vf1'} -q $CFG{'q'} -P $CFG{'P'} -r -m $CFG{'m'} $dir_s/batch.clean.sh\n" if $step =~ /1/;
print C1 "perl /home/fangchao/bin/qsub_all.pl -N B.r -d $dir_s/qsub_2 -l vf=$CFG{'vf2'},p=$CFG{'pro'} -q $CFG{'q'} -P $CFG{'P'} -r -m $CFG{'m'} $dir_s/batch.rmhost.sh\n" if $step =~ /2/;
print C1 "perl /home/fangchao/bin/qsub_all.pl -N B.s -d $dir_s/qsub_3 -l vf=$CFG{'vf3'},p=$CFG{'pro'} -q $CFG{'q'} -P $CFG{'P'} -r -m $CFG{'m'} $dir_s/batch.soap.sh\n" if $step =~ /3/;
print C1 "perl /home/fangchao/bin/qsub_all.pl -N B.a -d $dir_s/qsub_4 -l vf=$CFG{'vf4'} -q $CFG{'q'} -P $CFG{'P'} -r -m $CFG{'m'} $dir_s/batch.abun.sh\n" if $step =~ /4/;
close C1;
## done! <- top exec batch scripts
#
## start <- contents of each batch scripts
open C2,">$out_dir/linear.$step.sh"; 
open B1,">$dir_s/batch.clean.sh";
open B2,">$dir_s/batch.rmhost.sh";
open B3,">$dir_s/batch.soap.sh";
open B4,">$dir_s/batch.abun.sh";
###############################
foreach my $sam (sort keys %SAM){ # operation on sample level
	### Write main batch scripts first.
	print C2 "sh $dir_sS/$sam.$step.sh \&\n";
	open LINE,"> $dir_sS/$sam.$step.sh";
	if ($step =~ /1/){             
		open SSC,">$dir_sS/$sam.clean.sh";
		print LINE "perl /home/fangchao/bin/qsub_all.pl -N B.c -d $dir_sS/qsub_$sam.1 -l vf=$CFG{'vf1'} -q $CFG{'q'} -P $CFG{'P'} -r -m $CFG{'m'} $dir_sS/$sam.clean.sh\n";
	}                              
	if ($step =~ /2/){             
		open SSR,">$dir_sS/$sam.rmhost.sh";
		print LINE "perl /home/fangchao/bin/qsub_all.pl -N B.r -d $dir_sS/qsub_$sam.2 -l vf=$CFG{'vf2'},p=$CFG{'pro'} -q $CFG{'q'} -P $CFG{'P'} -r -m $CFG{'m'} $dir_sS/$sam.rmhost.sh\n";
	}                              
	if ($step =~ /3/){             
		open SSS,">$dir_sS/$sam.soap.sh";
		open LIST,">$dir_sp/$sam.soap.list";
		print LINE "perl /home/fangchao/bin/qsub_all.pl -N B.s -d $dir_sS/qsub_$sam.3 -l vf=$CFG{'vf3'},p=$CFG{'pro'} -q $CFG{'q'} -P $CFG{'P'} -r -m $CFG{'m'} $dir_sS/$sam.soap.sh\n";
	}
	if ($step =~ /4/){
		print LINE "perl /home/fangchao/bin/qsub_all.pl -N B.a -d $dir_sS/qsub_$sam.4 -l vf=$CFG{'vf4'} -q $CFG{'q'} -P $CFG{'P'} -r -m $CFG{'m'} $dir_sS/$sam.abun.sh\n"; 
		print B4 "sh $dir_sS/$sam.abun.sh\n";
	}
	close LINE;                    

	my $list ="";
	my @FQS = sort keys %{$SAM{$sam}};
	while(@FQS >0){ # Fastqs processed under this loop
		my @fqs = ($pattern eq "pe")?(shift @FQS, shift @FQS):(shift @FQS);
		my $fq1 = $SAM{$sam}{$fqs[0]};
		my $fq2 = $SAM{$sam}{$fqs[1]}||die "miss fq2 under pe pattern. $!\n" if @fqs eq 2;
		my $pfx = $fqs[0];
		$tmp_out = $fq1;
		if (@fqs eq 2){
			my @a = $fqs[0] =~/^(\S+)([.-_])([12ab])$/;
			my @b = $fqs[1] =~/^(\S+)([.-_])([12ab])$/;
			die "Does $fqs[0] and $fqs[1] seems not belong to a pair fq? Make sure they got same string before [.-_][12ab]\n" if $a[0] ne $b[0];
			$pfx = $a[0]; 
		}

###############################
		if ($step =~ /1/){
			open SIC,">$dir_sI/$pfx.clean.sh";
			my $seq = "";
			if (@fqs eq 2){
				$seq = "$fq1,$fq2";
				($SAM{$sam}{$fqs[0]}, $SAM{$sam}{$fqs[1]}) = ("$dir_c/$pfx.clean.fq1.gz","$dir_c/$pfx.clean.fq2.gz");
			}else{
				$seq = $fq1;
				$tmp_out = "$dir_c/$pfx.clean.fq.gz";
			}
			print SIC "perl $s_clean $seq $dir_c/$pfx $CFG{'Qt'} $CFG{'l'} $CFG{'N'} $CFG{'Qf'} $CFG{'lf'}\n";
			print B1 "sh $dir_sI/$pfx.clean.sh\n";
			print SSC "sh $dir_sI/$pfx.clean.sh\n";
			close SIC;
		}
###############################
		if ($step =~ /2/){
			open SIR,">$dir_sI/$pfx.rmhost.sh";
			my $seq = "";
			if (@fqs eq 2){
				$seq = "-a $SAM{$sam}{$fqs[0]} -b $SAM{$sam}{$fqs[1]}";
				($SAM{$sam}{$fqs[0]}, $SAM{$sam}{$fqs[1]}) = ("$dir_r/$pfx.rmhost.1.fq.gz","$dir_r/$pfx.rmhost.2.fq.gz");
			}else{
				$seq = "-a $tmp_out";
				$tmp_out = "$dir_r/$pfx.rmhost.fq.gz";
			}
			print SIR "perl $s_rm $seq -d $s_db -m 4 -s 32 -s 30 -r 1 -v 7 -i 0.9 -t 8 -f Y -p  $dir_r/$pfx -q\n";
			print B2 "sh $dir_sI/$pfx.rmhost.sh\n";
			print SSR "sh $dir_sI/$pfx.rmhost.sh\n";
			close SIR;
		}
###############################
		if ($step =~ /3/){
			open SIS,">$dir_sI/$pfx.soap.sh";
			my $seq = "";
			if (@fqs eq 2){
				$seq = "-i1 $SAM{$sam}{$fqs[0]} -i2 $SAM{$sam}{$fqs[1]}";
				$list .="$dir_sp/$sam.gene.build/$pfx.soap.pair.pe.gz\n";
			}else{
				$seq = "-i1 $tmp_out";
			}
			print SIS "perl $s_soap $seq -o $dir_sp -s $sam -p $pfx > $dir_sp/$pfx.log\n";
			print B3 "sh $dir_sI/$pfx.soap.sh\n";
			print SSS "sh $dir_sI/$pfx.soap.sh\n";
			$list .="$dir_sp/$sam.gene.build/$pfx.soap.pair.se.gz\n";
			close SIS;
		}
	}
	if ($step =~ /3/){print LIST $list; close LIST;};
	close SSC; close SSR; close SSS;

	if ($step =~ /4/){ # Since step4 contains abundance building which needs operated on sample level, I've got to put them here.
		open ABUN,">$dir_sS/$sam.abun.sh";
		print ABUN "perl $s_abun -ins $ins_f -l  $dir_sp/$sam.soap.list -o $dir_sp -p $sam\n";
		close ABUN;
	}
}
close B1;
close B2;
close B3;
close B4;
print C2 "wait\n"; close C2;
## done! <- contents of each batch scripts

# ####################
# SUB FUNCTION
# ####################
sub version {
	print <<VERSION;
	version:	v0.12
	update:		20160111
	author:		fangchao\@genomics.cn

VERSION
};

