#!/usr/bin/perl -w
use warnings;
use strict;
use File::Basename; 

die &usage if @ARGV < 6;
sub usage {
	print <<USAGE;
usage:
se pattern:
	perl $0 fq1 <prefix> <Qual system(33|64)> <min length> <seed OA> <fragment OA>
e.g	perl $0 sample.fq clean 33 30 0.99 0.90
USAGE
	exit;
}
sub openMethod {shift;return(($_=~/\.gz$/)?"gzip -dc $_|":"$_")}

### BODY ###
my ($fq,$pfx,$Qsys,$minLen,$Scut,$Qcut) = @ARGV;
$Qsys ||= 33;

open FQ,"gzip -dc $fq |",or die "error\n";
open OUT,"|gzip >$pfx.clean.fq.gz" or die "error OUT\n";
open STAT,"> $pfx.clean.stat_out",or die "error\n";
#open LOG,"> $pfx.clean.log",or die "error\n";

my %STAT;
my ($total, $remainQ, $sum_bp, $sum_oa, $sum_s, $max_bp, $min_bp) = (0, 0, 0, 0, 0, 0, 1e9);
#my %DEBUG if $debug;

while(<FQ>){
	#FQ info
	my ($seq,$num,$qual,$originLength,$Tlength,$Aqual,$start,$len,$count,$avgQ) =();
	chomp;
	my @a =split;
	(my $fqID = $a[0]) =~ s/\/[12]$//;
	chomp($seq = <FQ>);
	chomp($num = <FQ>);
	chomp($qual= <FQ>);
	$total ++;
	$originLength = length($seq);
	# trim
    #my ($Aqual,$start,$end) = &aQC_area($qual,$Qsys,$minLen,$fragQ);
    ($Aqual,$start,$len) = &ca1_cut($Scut,$Qcut,$Qsys,$qual);
    $len = $len - $start;
	$seq = substr($seq,$start,$len);
    $qual= substr($qual,$start,$len);
    # filter
    if( $len >= $minLen && $Aqual >= $Qcut) {
#		print LOG "$Aqual\t$start\t$len\n";
        print OUT "$fqID length=$len\n$seq\n$num\n$qual\n";
        # stat
        $remainQ ++;
		$STAT{$len} ++;
        $max_bp = ($max_bp > $len)?$max_bp:$len;
        $min_bp = ($min_bp < $len)?$min_bp:$len;
        $sum_bp += $len;
        $sum_s  += $start;
        $sum_oa += $Aqual;
    }
}
close FQ;
close OUT;

my $avgL = sprintf("%.0f",$sum_bp / $remainQ);
my $avgOA= sprintf("%.4f",$sum_oa / $remainQ);
my $avgS = sprintf("%.4f",$sum_s  / $remainQ);
my $rate = sprintf("%.4f",$remainQ / $total);
my $tag = basename($pfx);
#my $debugHead = ($debug)?"\tN>$n|Len<$lf|PQ<$Qf|N+Len|N+PQ|Len+PQ|HOMER":"";

print STAT "Total\tmax\tmin\tavgLen\tavgStart\tavgOA\t#remain\trate\tSampleTAG(minLen=$minLen,Qcut=$Qcut)\n";
print STAT "$total\t$max_bp\t$min_bp\t$avgL\t$avgS\t$avgOA\t$remainQ\t$rate\n";
foreach my $l(sort {$a<=>$b} keys %STAT){
	print STAT "$l\t$STAT{$l}\n";
}
close STAT;
# sub

sub aQC_area {
    my ($seq,$Qshift,$minLen,$fragQC) = @_;
    my $fragA = 1 - 10**(-$fragQC/10);
    my (@Q_a,@Q_b,@Q_b1,$ca_b1) = ();
    @Q_b = ();
    my $s = 0;
    my ($ca,$a,$i);
    for($i=0;$i<length($seq);$i++){
        my $q = substr($seq,$i,1);
           $q = ord($q) - $Qshift;
           $a = 1 - 10**(-$q/10);
        push @Q_a,$q;
        @Q_b1 = sort @Q_a;
        shift @Q_b1;
        $ca_b1= &ca_cal(@Q_b1);
        
        # judge
        if ($i>=$minLen && $ca_b1 < $fragA){
            #    return($ca,$s,$i);
            last;
        }
        $ca = $ca_b1;
    }
    return($ca,$s,$i);
}

sub ca1_cut {
    my $Sc  = shift @_;
    my $cut = shift @_;
    my $sysQ = shift @_;
    my $q = shift @_;
    my ($ca, $min, $tmp,$oa0, $oa1, $s,$p) = (1, 0, 1, 1, 1, 0, 0);
    my @Q;
    # cal phrd Q
    while($p<length($q)){
        $_ = substr($q,$p,1);
        $_ = ord($_) - $sysQ;
        $_ = 1 - 10**(-$_/10);
        $_ = ($_==0)?0.1:$_;
        push @Q, $_;
        $p ++;
    }
    # cal first seed OA
    $p = 0;
    my @seedOA = (1);
    while($p<30){
        $seedOA[0] *= $Q[$p];
        $p ++;
    }
    # choose best seed
    while($p<length($q)){
        $seedOA[$p-29] = $seedOA[$p-30] * $Q[$p] / $Q[$p-30];
        $s = ($seedOA[$p-29] > $seedOA[$s])?$p-29:$s;
        $p++;
        last if $seedOA[$s]  >= $Sc;
    }
    # trim
#    $ca = $seedOA[$s];
    $p = $s + 30;
    $ca = $seedOA[$s];
    while($p<length($q)){
        my $acc = $Q[$p];
#        $oa0 *= $acc;
        if($acc < $min){
            $oa1 = $ca * $min;
            $min = $acc;
        }else{
            $oa1 = $ca * $acc;
        }
        last if $oa1 < $cut;
        $p ++;
        $ca = $oa1;

    }
    return($ca,$s,$p);
}




