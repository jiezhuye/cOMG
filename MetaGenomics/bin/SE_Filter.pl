#!/usr/bin/perl -w
use warnings;
use strict;
use File::Basename; 

die &usage if @ARGV <=7;
sub usage {
	print <<USAGE;
usage:
se pattern:
	perl $0 fq1 <prefix> <Q cutoff for trim> <Max trim length> <#N allowed> <Q cutoff for filter> <min length of reads allowed> <Qual system(33|64)>
e.g	perl $0 sample.fq clean 30 10 1 30 35
USAGE
	exit;
}
sub openMethod {shift;return(($_=~/\.gz$/)?"gzip -dc $_|":"$_")}

### BODY ###
my ($fq,$pfx,$Qt,$l,$n,$Qf,$lf,$Qsys) = @ARGV;
$Qsys ||= $Qsys;

open FQ,"gzip -dc $fq |",or die "error\n";
open OUT,"|gzip >$pfx.clean.single.fq.gz" or die "error OUT\n";
open STAT,"> $pfx.clean.stat_out",or die "error\n";

my @total = (0,0);
my(@remainQ,@sum_bp)= ();
my @max_bp = (0,0);
my @min_bp = (10000,10000);

my %READ;
while(<FQ>){
	#FQ info
	my ($seq,$num,$qual,$originLength,$Tlength,$len,$count,$avgQ) =();
	chomp;
	my @a =split;
	(my $pfx1 = $a[0]) =~ s/\/[12]$//;
	chomp($seq = <FQ>);
	chomp($num = <FQ>);
	chomp($qual= <FQ>);
	$total[0] ++;
	$originLength = length($seq);
	# trim
	$Tlength = &Qstat($qual,$Qt,"trim",$l);
	$len = $originLength - $Tlength;
	$seq = substr($seq,0,$len);
	$qual= substr($qual,0,$len);
	# filter
	$count = $seq=~tr/N/N/;
	$avgQ  = &Qstat($qual,$Qf,"filter");
	if($count <= $n && $len >= $lf && $avgQ >= $Qf){		# N number & length limit judgement
		print OUT "$pfx length=$len\n$seq\n$num\n$qual\n";
		# stat
		$remainQ[0] ++;
		$max_bp[0] = ($max_bp[0] > $len)?$max_bp[0]:$len;
		$min_bp[0] = ($min_bp[0] < $len)?$min_bp[0]:$len;
		$sum_bp[0] += $len;
	}
}
close FQ;
close OUT;

my $avgL = $sum_bp[0] / $total[0];
my $rate = $remainQ[0] / $total[0];
my $tag = basename($pfx);

print STAT "Total\tmax\tmin\tavg\t#remain\trate\tSampleTAG(trim=$l,Qt=$Qt,N=$n,Qf=$Qf,min=$lf)\n";
print STAT "$total[0]\t$max_bp[0]\t$min_bp[0]\t$avgL\t$remainQ[0]\t$rate\t$tag\n";

close STAT;

# sub
sub Qstat {
	my ($q_l,$q_n,$method,$c_n) = @_;
	my $c = 0;

	if($method eq "trim"){
		for(my $i=length($q_l)-1;$i>=0;$i--){
			my $q=substr($q_l,$i,1);
			$q=ord$q;
			$q=$q - $Qsys;
			last if($q>=$q_n || $c>=$c_n);
			$c++;
		}
	}elsif($method eq "filter"){
		for(my $i=length($q_l)-1;$i>=0;$i--){
			my $q=substr($q_l,$i,1);
			$q=ord$q;
			$q=$q -$Qsys;
			$c += $q;
		}
		$c = ($c/length($q_l) >= $q_n)?0:length($q_l);
	}
	return($c);
}



