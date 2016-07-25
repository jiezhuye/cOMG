#!/usr/bin/perl
use strict;

my $usage = "USAGE:
	perl <map> <work dir> <steps> > outputfile
	map: seq_id\tsample_id.\n";
die $usage if @ARGV <3;
my ($map,$wd,$step)=@ARGV;


$wd =~ s/\/$//;
my (%STAT,%MAP,%ABUN);
#directories location
my $d_clean = "$wd/clean";
my	$d_rmhost = "$wd/rmhost";
my	$d_soap = "$wd/soap";

open MAP,"<$map" or die $!;
while(<MAP>){
	chomp;
	my @a = split;
	$MAP{1}{$a[1]}=$a[0];
	$MAP{2}{$a[0]}=$a[1];
}

my @steps =("none","filter","rmhost","soap","abun");
if($step =~ /1/){
	my @samples = `ls $wd/clean/|grep clean.stat_out|sed 's/.clean.stat_out//'`;
	while ($#samples >-1){
		my(@heads,@vals)=();
		chomp(my $sam = shift @samples);
		open SC,"< $wd/clean/$sam.clean.stat_out" or die "can note open $wd/clean/$sam.clean.stat_out!".$!;
		chomp($_=<SC>);@heads = split;
		chomp($_=<SC>);@vals = split;
		@{$STAT{$sam}{1}{'H'}} = @heads;
		for (my $i=0;$i<=$#heads;$i++){
			$STAT{$sam}{1}{$heads[$i]} = $vals[$i];
		}
		close SC;
	}
}

if($step =~ /2/){
	my @samples = `ls $wd/rmhost/|grep rmhost.stat_out|sed 's/.rmhost.stat_out//'`;
	while ($#samples >-1){
		my(@heads,@vals)=();
		chomp(my $sam = shift @samples);
		open SC,"< $wd/rmhost/$sam.rmhost.stat_out" or die $!; 
		chomp($_=<SC>);@heads = split;
		chomp($_=<SC>);@vals = split;
		@{$STAT{$sam}{2}{'H'}} = @heads;
		for (my $i=0;$i<=$#heads;$i++){
			$STAT{$sam}{2}{$heads[$i]} = $vals[$i];
		}
		close SC;
	}   
}

if($step =~ /3/){
	my @samples = `ls $wd/soap/*build/|grep soap.pair.log|sed 's/.soap.pair.log//'`;
	while ($#samples >-1){
		my(@heads,@vals)=();
		chomp(my $sam = shift @samples);
		open SC,"tail -9 $wd/soap/*.gene.build/$sam.soap.pair.log|" or die $!;               
		chomp($_=<SC>);@heads = split /\s+|\t/;
#		@heads = split(/\s+|\t/,$line);
		@{$STAT{$sam}{3}{'H'}} = ('Reads','aligned');
		$STAT{$sam}{3}{'Reads'} = $heads[2];
		chomp($_=<SC>);@vals = split /\s+|\t/;
#		@vals = split(/\s+|\t/,$line);
		$STAT{$sam}{3}{'aligned'} = $vals[1];
		close SC;
	}
}

if($step =~ /4/){
	my @samples = `ls $wd/soap/|grep abundance.size|sed 's/.abundance.size//'`;
	while ($#samples >-1){
		chomp(my $sam = shift @samples);
		chomp(my $size=`cat $wd/soap/$sam.abundance.size`);
		@{$STAT{$MAP{2}{$sam}}{4}{'H'}} = "size";
		$STAT{$MAP{2}{$sam}}{4}{'size'} = $size;
	}   
}

my $time =1;
#my $label = "id\tsample";
my $title = "id\tsample";
my $content = "";
foreach my $sam ( sort keys %STAT ){
	$content .="$sam\t$MAP{1}{$sam}";
	foreach my $part (sort keys %{$STAT{$sam}}){
		foreach my $head (@{$STAT{$sam}{$part}{'H'}}){
			#$label .= "\t$part" if $time;
			$title .= "\t$steps[$part]\_$head" if $time;
			$content .= (defined $STAT{$sam}{$part}{$head})?"\t$STAT{$sam}{$part}{$head}":"\tNA";
		}
	}
#		$label .= "\n" if $time;
		$title .= "\n" if $time;
		$time = 0;
		$content .= "\n";
}
print "$title"."$content";









