#!/usr/bin/perl -w
use strict;
die &usage unless @ARGV >= 4;
my($targetSize,$reads,$length,$out,$single_double) = @ARGV;
# $single_double means weather the reads counts need to be counted tiwce (because some pair-end abundance calculate 1 read as half a *pair*)
$single_double ||= 1;
sub openMethod{my $f=shift;return((($f =~ /\.gz$/)?"gzip -dc $f|":"$f"))}
################################## downsize ######################################

my $gss = 0; # gene set size of $reads
my (%reads_num,@rands);
open I,&openMethod($reads) or die "$!\n";
open ST, ">$out.abundance";
my $total_reads=0;
my $k=0;
while(<I>)
{
    chomp;
    my @temp=split;
	next if $.==1 && $temp[1]=~/[a-z]/;
 	$gss ++;
	$total_reads+= $temp[1] * $single_double ;
    $reads_num{$temp[0]}=$temp[1] * $single_double;
	if ($temp[1] >0){
		my $t=$temp[1];
		while($t){
			$rands[$k] = $temp[0];
			$k ++;$t --;
		}
	}
}
close I;

my $time=$total_reads-$targetSize; 
if ($time < 0){
	print ST "Less than $targetSize ($total_reads). Discarded.\n";
	exit;
}else{
	while($time){
	  	my $point=int(rand(@rands));
	    $reads_num{$rands[$point]} --;
		splice(@rands,$point,1);
	    $time --;
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
close I;
print ST "ID\treads_pairs\tbase_abundance\treads_abundance\n";
for my $i(1 .. $gene_n) {
	print ST "$i\t$reads_num{$i}\t",$reads_num{$i}/$targetSize,"\t",$reads_abundance{$i}/$total_abundance,"\n";
}

close ST;
sub usage
{
    print "usage:perl $0 [targetSize][reads table][len.info][output prefix]\n
			The number of reads you wanna trim.
			A list contain the gene id and reads number(gene & reads number before downsize)
			A list contain the gene id and its length(gene length reference)
			output prefix\n";
exit;
}
