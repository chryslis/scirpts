#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $input = "/media/chrys/HDDUbuntu/DataStorage/BedCov/4169.CovergaePerNuc.bed";
my $output = "/media/chrys/HDDUbuntu/DataStorage/BedCov/AvgCovPerNu";

open (READ,$input) || die "Could not open $input : $!";
open(OUTPUT,">",$output) || die "Could not create $output : $!";

print "Inputs and Outputs ready...\n";

my %calcHash;
my @Nucleotides;
my @ReadCount;

my $globalLine = <READ>;
chomp $globalLine;
my @globalTemp = split("\t",$globalLine);
my $oldID = $globalTemp[3];

print "Reading file...\n";

while (<READ>) {
	chomp;

	my $line = $_;

	my @temp = split("\t",$line);

	#Temp storage contains standard start<->stop [0:2], ID of the feature on [3]
	#Nucleotide Number of feature on [4], Reads per nucleotide is [5]

	my $ID = $temp[3];

	if ($ID eq $oldID) {

		my $NuPos = $temp[4];
		my $depth = $temp[5];

		push(@Nucleotides,$NuPos);
		push(@ReadCount,$depth);

		@Nucleotides = sort @Nucleotides;

		

	}else{

		my $FeatureLength = scalar (@Nucleotides)+1;

		my $sum = 0;
		foreach $_(@ReadCount){

			$sum += $_;

		}

		my $average = $sum/$FeatureLength;

		print "Printing to output...\r";

		print OUTPUT "$oldID\t$FeatureLength\t$sum\t$average\n";

		@Nucleotides = ();
		@ReadCount = ();

	}

	$oldID = $ID;

	#$calcHash{$ID}{$NuPos} = $depth;
}

print "\nDone!\n";



