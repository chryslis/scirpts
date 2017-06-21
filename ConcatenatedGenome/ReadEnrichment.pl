#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);
use File::Basename;
use Cwd;

my $start = time();
my $current = 0;

#File containing the Reads with the IDs
#my $input = $ARGV[0];
my $input = "/home/chrys/Documents/thesis/data/analysis/ConcatenatedGenome/Concat.22517/Alignments.DNASE154/Shuffle.DNASE154/DNASE154.Features.15";

#Sorting by super or by species
#my $sortType = $ARGV[1];
my $sortType = "F";

#Location of the weight vector
#my $weightVecor = $ARGV[2];
my $weightVecor = "/home/chrys/Documents/thesis/data/analysis/ConcatenatedGenome/Concat.22517/Alignments.DNASE154/DNASE154.ReadWeightVector";

#Location of the List containing the Occurences of the species or families in the genome
#my $famCounts = $ARGV[3];

my $famCounts = "/home/chrys/Documents/thesis/data/analysis/ConcatenatedGenome/Concat.22517/Alignments.DNASE154/DNASE154.SummarySuper";
#Just declared here for global
my $selection;

if ($sortType eq "F") {
	$sortType = 2;
	$selection="SuperFamily"


}elsif($sortType eq "S"){
	$sortType = 1;
	$selection="Species"

}else{
	$sortType = 2;
	$selection="SuperFamily"
}

#Reading prepared weight Vector
open(GETWEIGHTS,$weightVecor) || die "Could not reade weight vector: $!";

#Just some feedback...
print "\tProcessing weight vector...\n";
#Hash for saving the weights of a specific read
my %weightsHash;

while (<GETWEIGHTS>) {
	chomp;
	my @temp = split("\t",$_);
	#File is ReadNumber weight with tab as delimiter
	$weightsHash{$temp[0]} = $temp[1];
}

close(GETWEIGHTS);

#Processing stuff to put everything in the proper folders

my $fileName = basename($input);
my @temp1 = split(/$fileName/,$input);
my $path = $temp1[0];
my $outPut = $path;
my @temp2 = split(/\./,$fileName);
my $len = $#temp2;
$temp2[$len-1] = "Enrichment.".$selection;
my $outName = join(".",@temp2);
my $outPutPath = $path.$outName."TESTING";



print "\tProcessing Features and Reads...\n";

open(READ,$input) || die "Could not read $input: $!";
my %CountingHash;
while (<READ>) {
	chomp;
	my @temp = split("\t",$_);
	my $sortingElement = $temp[$sortType];
	my $read = $temp[0];
	$CountingHash{$read}{$sortingElement} += 1;
}

open(OUTPUT,">$outPutPath" ) || die "Could not create $outPutPath:$!";;

print"\tDoing weight calculations...\n";
my %resultHash;


foreach my $Reads(keys %weightsHash){

	if ( exists $CountingHash{$Reads} ) {

		foreach my $fam (keys %{$CountingHash{$Reads}} ){

			my $FamilyPerReadCount = $CountingHash{$Reads}{$fam};
			my $weight = $weightsHash{$Reads};

			$resultHash{$fam} += $FamilyPerReadCount*$weight;
		}
	}
}

#Created counts of families beforehand to save time. Just reading a file with max ~1300 lines
open(GETFAMCOUNTS,$famCounts) || die "Could not open $famCounts: $!";

my %famCounts;

while (<GETFAMCOUNTS>){
	chomp;
	my @temp = split("\t",$_);
	my $fam = $temp[0];
	my $count = $temp[1];

	$fam =~ s/^\s+|\s+$//g;
	$famCounts{$fam} = $count;
}

print "\tPrinting Outputs!\n";

foreach my $keys(sort keys %resultHash){
	my $norm = $resultHash{$keys}/$famCounts{$keys};
	print OUTPUT "$keys\t$resultHash{$keys}\t$famCounts{$keys}\t$norm\n";

}

close(READ);
close(OUTPUT);

my $stop = time();
my $runTime = int((($stop - $start)/60));

print "\n";
print "\tDone!\t Finished in $runTime Minutes.\n";
