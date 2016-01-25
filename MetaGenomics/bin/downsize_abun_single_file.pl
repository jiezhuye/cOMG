#!/usr/bin/perl -w
use strict;
die &usage unless @ARGV == 4;
my($targetSize,$reads,$length,$out) = @ARGV;

################################## downsize ######################################

my $gss = 0; # gene set size of $reads
my %reads_num;
open I,"$reads" or die "$!\n";
open ST, ">$out.downsize.abundance";
my $total_reads=0;
while(<I>)
{
    chomp;
    my @temp=split;
 	$gss ++;
	$total_reads+=$temp[1];
    $reads_num{$temp[0]}=$temp[1];

}
close I;

my $time=$total_reads-$targetSize; 
if ($time < 0){
	print ST "Less than $targetSize. Discarded.\n";
}else{
	while($time){
	  	my $point=int(rand($gss)+1);
	   	if($reads_num{$point} > 0){
	    	$reads_num{$point} --;
	    	$time --;
	    }
	}
}	

################################ abundance ################################

open I,"$length" or die "$!\n";
my $gene_n=0;###size of gene length profile
my %reads_abundance;### reads_abundance=reads number/gene length
my $total_abundance=0;### total_abundance of reads_abundance
### base_abundance=reads_num/total_reads_number 
while(<I>){  
    chomp;
    my @temp=split "\t",$_;
    $gene_n++;
	$reads_num{$temp[0]}||=0;
	if($reads_num{$temp[0]}==0){
		$reads_abundance{$temp[0]}=0;
	}else{
		if($temp[2]==0){next;}else{
			$reads_abundance{$temp[0]}=$reads_num{$temp[0]}/$temp[2];
			$total_abundance+=$reads_abundance{$temp[0]};
		}	
	}
}
print "$gene_n\n";
print ST "ID\treads_pairs\tbase_abundance\treads_abundance\n";
for my $i(1 .. $gene_n) {
	print ST "$i\t$reads_num{$i}\t",$reads_num{$i}/$targetSize,"\t",$reads_abundance{$i}/$total_abundance,"\n";
}

sub usage
{
    print "usage:perl $0 [targetSize][reads table][len.info][output prefix]\n
			The number of reads you wanna trim.
			A list contain the gene id and reads number(gene & reads number before downsize)
			A list contain the gene id and its length(gene length reference)
			output prefix
		  ";
    exit;
}
