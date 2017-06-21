#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper qw(Dumper);

my $inPut = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/Alignments/DNAseSet/ConcatenatedGenome.RepMaskMerged.4169";
#my $inPut = "TestGenome";
my %CountingHash;
my $sequence;
my $header;

open(READ,$inPut) || die "Could not open $inPut: $!";
open(OUTPUT,">","ConcatenatedGenome.Size.RepMaskMerged.4169") || die "Could not open!";

while (<READ>) {
	
	print "Working...\n";
	chomp;

	if ($_ =~ /^>/g) {

		$sequence = undef;
		$header = $_;
		$header =~ s/>//;
		
	}else{

		$sequence = $sequence.$_;
	}

	$CountingHash{$header} = $sequence;
}

foreach my $key(sort keys %CountingHash){

	my $len = length($CountingHash{$key});
	print OUTPUT "$key\t$len\n";
}

print "Done\n";


