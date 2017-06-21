#!/usr/bin/perl

use warnings;
use strict;
#use Data::Dumper qw(Dumper);

my $shuffleFile = $ARGV[0];
my $shuffleIndex = $ARGV[1];
#my $shuffleFile = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/Shuffle/4169.Shuffled.Intersect.Sorted";

#Created a list from all mapped reads (unique list)
my $ReadList = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/Shuffle/Uniq.Reads.mapped";

open(READ,$shuffleFile) || die "Could not open $shuffleFile: $!";
open(READLIST,$ReadList) || die "Could not open $ReadList $!";

my @UniqReads;

print "\tReading unique reads...\n";

while (<READLIST>) {
	chomp;
	my @temp = split(/\./,$_);
	push(@UniqReads,$temp[1]);
}

print "\tProcessing...\n";

my @sortedUniqReads = sort {$b <=> $a} @UniqReads;

my $outPut = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/Shuffle/4169.Shuffled.UnionMapped.$shuffleIndex.bed";

open(OUT,">",$outPut) || die "Could not create file! $!";

my %outHash;

print "\tPreparing sorting...\n";
my $len = scalar(@UniqReads);


while (<READ>){

	chomp;
	my $line = $_;
	my @temp = split("\t",$_);
	my @temp2 = split(/\./,$temp[3]);
	my $readID = $temp2[1];

	unless (exists $outHash{$readID}){

		$outHash{$readID} = [$line];

	}else{

		push ( @{$outHash{$readID}} , $line );

	}
}

print "\tProcessing output...\n";
my $i = 0;

foreach my $mappedread(@UniqReads){

	my $progress = int(($i/$len)*100);
	print "\tCurrently at $progress % progess \r";
	$i++;

	if (exists $outHash{$mappedread}) {

		foreach my $arrays(@{$outHash{$mappedread}}){
			print OUT "$arrays\n";	
		}
	}
}

print "\n";
close(OUT);
close(READ);
close(READLIST);
print "\tDone!\n";