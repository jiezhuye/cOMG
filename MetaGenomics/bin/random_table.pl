#!/usr/bin/perl -w
use strict;
use PerlIO::gzip;

sub usage{
	print <<EOD;
usage: perl $0 [random file] [gene length list] [output prefix]

	Contact: caixianghang \@genomics.org.cn
	Updated: 2014/11/7
EOD
}

do{&usage();exit;} unless @ARGV==3;
my($if,$len,$out) = @ARGV;
my (%id,%abundance,$totalabundance,$totalreads,%lengths);
my $num;
my $gene_n;
open I,"<:gzip(autopop)","$if" or die "$!\n";
while(<I>)
{
    chomp;
    $id{$_} ++;
    $num++;
}
close I;

open I,"<:gzip(autopop)","$len" or die "$!\n";
while(<I>)
{
    chomp;
    my @temp=split;
	$gene_n++;
    next if ($temp[2] == 0);
    $lengths{$temp[0]}=$temp[2];
}
close I;


for my $i( 1 .. $gene_n)
{
    unless(defined $id{$i}) {
        $id{$i}=0;
		$abundance{$i}=0;
    }
    $abundance{$i}=$id{$i}/$lengths{$i};
    $totalabundance+=$abundance{$i};
    $totalreads+=$id{$i};
}

open OT,">$out.abundance" or die "$out.abundance $!\n";
print OT "ID\treads_pairs\tbase_abundance\treads_abundance\n";
for my $i(1 .. $gene_n) {
    print OT "$i\t$id{$i}\t",$id{$i}/$totalreads,"\t",$abundance{$i}/$totalabundance,"\n";
}

close OT;
print "$totalreads\n"
