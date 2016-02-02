#!/usr/bin/perl -w
use strict;

die &usage unless @ARGV == 4;

my(%total,%id,%lengths,%abundance,%totalabundance,%totalreads);
#my($if,$it,$len,$out) = @ARGV;
my($targetSize,$it,$len,$out) = @ARGV;
#my $targetSize; # The # of reads u wanna trim to.
my $gss = 0; # gene set size
=cut
open I,"$if" or die "$!\n";
while(<I>)
{
    chomp;
    my @t=split;
    $total{$t[0]}=$t[1];
}
close I;
=cut
open ST,">$out.stat" || die "Cant open $out.stat. ".$!;
open I,"$len" or die "$!\n";
while(<I>)
{
    chomp;
    my @temp=split;
	$gss ++;
    next if ($temp[2] == 0);
    $lengths{$temp[0]}=$temp[2];

}
close I;

open I,"$it" or die "$!\n";
my $name=(split /\./,$it)[0];
my $basename=(split /\//,$name)[-1];
my $head = <I>; chomp($head);
my @heads = split(/\t/,$head);
while(<I>)
{
    chomp;
    my @temp=split;

	for (my $i=1;$i<@temp;$i++){
	    $id{$heads[$i]}{$temp[0]}=$temp[$i];
		$total{$heads[$i]} += $temp[$i];
	}
}
close I;

for (my $h=1;$h<@heads;$h++){
	my $time=$total{$heads[$h]}-$targetSize;
	if ($time < 0){
		print ST "$heads[$h] is less than $targetSize. Discarded.\n";
		splice @heads,$h,1;
		$h --;
		next;
	}
	while($time){
	    my $point=int(rand($gss)+1);
	    if($id{$heads[$h]}{$point} > 0){
	        $id{$heads[$h]}{$point} --;
	        $time --;
	    }
	}

	for my $i( 1 .. $gss) {
	    $id{$heads[$h]}{$i} ||= 0;
	    $abundance{$heads[$h]}{$i}=$id{$heads[$h]}{$i}/$lengths{$i};
	    $totalabundance{$heads[$h]}+=$abundance{$heads[$h]}{$i};
#	    $totalreads{$heads[$i]}+=$id{$heads[$i]}{$i};
	}
}
open OTR,">$out.reads.profile" or die "$out.profile $!\n";
open OTA,">$out.abun.profile" or die "$out.profile $!\n";
#open ST,">$out.stat" || die $!;
#print OT "ID\treads_pairs\tbase_abundance\treads_abundance\n";
$head = join("\t",@heads);
print OTR $head."\n";
print OTA $head."\n";

for my $i(1 .. $gss) {
	print OTR "$i";
	print OTA "$i";
	for my $h(1 .. $#heads){
		my $abun = $abundance{$heads[$h]}{$i}/$totalabundance{$heads[$h]};
#	    print OT "\t$id{$head[$h]}{$i}\t",$id{$head[$h]}{$i}/$totalreads{$head[$h]},"\t",$abundance{$head[$h]}{$i}/$totalabundance{$head[$h]};
		print OTR "\t$id{$heads[$h]}{$i}";
		print OTA "\t$abun";
	}
	print OTR "\n";
	print OTA "\n";
}
close OTR;
close OTA;
close ST;
#print ST "";
#--------------------------------------------------------
sub usage
{
    print "usage:perl $0 [number table] [abundance table] [len.info] [output table]\n
			A list contain the file basename and the total reads number
			A table of reads profile
			A list contain the gene id and its length
			output filename
";
    exit;
}
