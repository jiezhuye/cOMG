#!/usr/bin/perl -w
use strict;
################################################################################
unless(4==@ARGV) {
    &usage;
    exit;
}
################################################################################
my($list_f,$order_f,$row,$out) = @ARGV;
my(@order,%list,@info,$i,%class,%cover,%Count);
################################################################################
open IN,"<$list_f" || die "read $list_f $!\n";
while(<IN>) {
    chomp;
    @info=split /\//;
    $info[-1]=~/^(\S+)\.abundance(|\.gz)$/;
    my $name =$1;
    $list{$name}=$_;
}
close IN;
################################################################################
open IN,$order_f or die "read $order_f $!\n";
while(<IN>) {
    chomp;
    push(@order,$_);
}
close IN;
################################################################################
for($i=0;$i<@order;++$i) {
	my $openMethod = ($list{$order[$i]} =~ /gz$/)?"gzip -dc $list{$order[$i]} |":"$list{$order[$i]}";
	open IN,$openMethod  or die "$!\n";
    <IN>;		# MAKE SURE YOUR ABUNDANCE FILE GOT A HEADER!!!
    while(<IN>) {
        chomp;
        @info=split /\t/;
        $class{$info[0]}.="\t".$info[$row];
		$cover{$info[0]} ||= 0; 
		$Count{$i} ||= 0;
		if ($info[$row] > 0){ $cover{$info[0]} =1; $Count{$i} ++ };
    }
    close IN;
}
################################################################################
open OT,">$out.profile" or die "write $out $!\n";
open CrT,">$out.cover" || die $!;
open CtT,">$out.count" || die $!;
for($i=0;$i<@order;++$i) {
    print OT "\t",$order[$i];
	print CtT "$order[$i]\t$Count{$i}\n";
}
print OT "\n";
foreach $i(sort {$a<=>$b} keys %class) {
    print OT $i,$class{$i},"\n";
	print CrT "$i\t$cover{$i}\n";
}
close OT;
close CrT;
################################################################################
sub usage {
    print STDERR<<USAGE;

    Description\n
    This programme is to combine profiling table\n
    Usage:  perl $0 [file.list] [order] [row] [outfile prefix]\n
    Row must be in 1(pairs),2(base_abundance),3(reads_abundance),4(depth_abundance)\n
    Author Libranjie,zhouyuanjie\@genomics.org.cn\n
    updated 2014/12/5 linyuxiang\@genomics.cn\n
	customized by fangchao\@genomics.cn # 20160118
USAGE
}
