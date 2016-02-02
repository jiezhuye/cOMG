use warnings;
use strict;

die "perl $0 [*.in] [*.outdir] [row(optional)]\n" unless @ARGV >= 2;

my ($in_f, $out_f, $row) = @ARGV;
die "Overlap In-Output...\n" if $in_f eq $out_f;

my (@gene, @sum, @shannon,$title,$shannon) = ();
if($in_f =~/\/([\w|\d|\.|\_|\-]+)\.(abundance|profile)\.gz$/){
	open IN,"gzip -dc $in_f|" or die $!;
	$title = $1;
}elsif($in_f =~/\/([\w|\d|\.|\_|\-]+)\.(abundance|profile)$/){
	open IN, $in_f or die $!;
	$title = $1;
}
chomp(my $h = <IN>);
my @head = split /\s+/, $h;
shift @head;
while (<IN>) { 
	chomp;
	my @s = split /\s+/;
	shift @s;
	if (not defined $row){
		for (0..$#s) {
			next if $s[$_]== 0;
			#$gene[$_]++;
			$sum[$_] += $s[$_];
			$shannon[$_] -= $s[$_] * log($s[$_]);
		}
	}else{
		next if $s[$row]== 0;
		$sum[$row] += $s[$row];
		$shannon[$row] -= $s[$row] * log($s[$row]);
	}
}
close IN;

open OT, ">$out_f/$title.shannon" or die "$!\n$out_f/$title.shannon";
if(defined $row){
	$shannon[$row] = $shannon[$row] / $sum[$row] +log($sum[$row]);
	print OT "$title\t$shannon[$row]\n";
}else{
	for(0..$#head){
	    $shannon[$_] = $shannon[$_] / $sum[$_] + log($sum[$_]);
		print OT "$head[$_]\t$shannon[$_]\n";
	}
}
close OT;

print STDERR "Program End...\n";
