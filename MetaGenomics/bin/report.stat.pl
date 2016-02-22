#!/usr/bin/perl
use strict;

my ($map,$wd,$step)=@ARGV;
$wd =~ s/\/$//;
my (%STAT,%MAP);
#directories location
my $d_clean = "$wd/clean";
my	$d_rmhost = "$wd/rmhost";
my	$d_soap = "$wd/soap";

open MAP,"<$map" or die $!;
while(<MAP>){
	chomp;
	my @a = split;
	$MAP{$a[1]}=$a[0];
}

if($step =~ /1/){
	my @samples = `ls $wd/clean/|grep clean.stat_out|sed 's/.clean.stat_out//'`;
	while ($#samples >-1){
		my(@heads,@vals)=();
		my $sam = shift @samples;
		open SC,"< $wd/clean/$sam.clean.stat_out" or die $!;
		<SC>;chomp;@heads = split;
		<SC>;chomp;@vals = split;
		for (my $i=0;$i<=$#heads;$i++){
			$STAT{$sam}{'clean'}{$heads[$i]} = $vals[$i];
		}
		close SC;
	}
}

if($step =~ /2/){
	my @samples = `ls $wd/rmhost/|grep rmhost.stat_out|sed 's/.rmhost.stat_out//'`;
	while ($#samples >-1){
		my(@heads,@vals)=();
		my $sam = shift @samples;
		open SC,"< $wd/rmhost/$sam.rmhost.stat_out" or die $!; 
		<SC>;chomp;@heads = split;
		<SC>;chomp;@vals = split;
		for (my $i=0;$i<=$#heads;$i++){
			$STAT{$sam}{'rmhost'}{$heads[$i]} = $vals[$i];
		}
		close SC;
	}   
}

if($step =~ /3/){
	my @samples = `ls $wd/soap/*build/|grep soap.pair.log|sed 's/.soap.pair.log//'`;
	while ($#samples >-1){
		my(@heads,@vals)=();
		chomp(my $sam = shift @samples);
		open SC,"tail -9 $wd/soap/$sam.gene.build/$sam.soap.pair.log|" or die $!;               
		chomp(my $line=<SC>);
		@heads = split(/\s+|\t/,$line);
		$STAT{$sam}{'soap'}{'clean_reads'} = $heads[2];
		chomp(my $line=<SC>);
		@vals = split(/\s+|\t/,$line);
		$STAT{$sam}{'soap'}{'mapped_reads'} = $vals[1];
		close SC;
	}
}
my $time =1;
my $label = "id\tsample";
my $title = "id\tsample";
my $content = "";
foreach my $sam ( sort keys %STAT ){
	$content .="$sam\t$MAP{$sam}";
	foreach my $part (sort keys %{$STAT{$sam}}){
		foreach my $head (sort keys %{$STAT{$sam}{$part}}){
			$label .= "\t$part" if $time;
			$title .= "\t$head" if $time;
			$content .= "\t$STAT{$sam}{$part}{$head}";
		}
		$label .= "\n" if $time;
		$title .= "\n" if $time;
		$time = 0;
		$content .= "\n";
	}
}
print "$label"."$title"."$content";









