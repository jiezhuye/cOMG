#!/usr/bin/perl -w
use strict;

die &usage unless @ARGV == 4;

my(%total,%id,%lengths,%abundance,%totalabundance,%totalreads);
my($if,$it,$len,$out) = @ARGV;
my $targetSize; # The # of reads u wanna trim to.
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
my @heads = split($head);
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

for (my $i=1;$i<@heads;$i++){
	my $time=$total{$heads[$i]}-$targetSize;
	while($time){
	    my $point=int(rand($gss)+1);
	    if($id{$point} > 0){
	        $id{$heads[$i]}{$point} --;
	        $time --;
	    }
	}

	for my $i( 1 .. $gss) {
	    $id{$heads[$i]}{$i} ||= 0;
	    $abundance{$heads[$i]}{$i}=$id{$heads[$i]}{$i}/$lengths{$i};
	    $totalabundance{$heads[$i]}+=$abundance{$heads[$i]}{$i};
	    $totalreads{$heads[$i]}+=$id{$i};
	}
}
open OTR,">$out.reads.profile" or die "$out.profile $!\n";
open OTA,">$out.abun.profile" or die "$out.profile $!\n";
#open ST,">$out.stat" || die $!;
#print OT "ID\treads_pairs\tbase_abundance\treads_abundance\n";
print OTR $head."\n";
print OTA $head."\n";

for my $i(1 .. $gss) {
	print OTR "$i";
	print OTA "$i";
	for my $h(1 .. @heads){
#	    print OT "\t$id{$head[$h]}{$i}\t",$id{$head[$h]}{$i}/$totalreads{$head[$h]},"\t",$abundance{$head[$h]}{$i}/$totalabundance{$head[$h]};
		print OTR "\t$id{$heads[$h]}{$i}";
		print OTA "\t$abundance{$heads[$h]}{$i}/$totalabundance{$heads[$h]}";
	}
	print OTR "\n";
	print OTA "\n";
}
close OTR;
close OTA;
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
