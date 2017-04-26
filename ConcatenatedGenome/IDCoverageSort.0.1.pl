#!/usr/bin/perl

use warnings;
use strict;
use Data::Dumper qw(Dumper);

my $start = time();
my $current = 0;

#Get original Index file from output of the Sorting (a.G.0.2)Script 
my $originalIndex = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/RepeatMaskerTrack.sorted.indexed.4169";

open(READ,$originalIndex) || die "Could not open $originalIndex!: $!";

#Storing IDs -> Family since the input file will contain multiple IDs seperated by "|""
print "Preparing Inputs...\n";

my %IDhash;
my %outHash;

print "Please pick sort type:\n3 - Species\n4 - Class\n5 - SuperFamily\n";
my $sortType = <STDIN>;
chomp $sortType;



#Read the Index file created from Merger Script
while (<READ>) {
	chomp;
	my $line = $_;
	#Split bed
	my @temp = split("\t",$line);

	#ID is stored in field 6 - zero based
	#In this file, IDs and Families are still line by line
	my $ID = $temp[6];
	my @primaryTemp = split(/\:/,$ID);

	#In the file, the ordering is with 1 based bed format: chr/start/stop/Sub-Families/Class/Super-Families.
	#For changing the respective family -> use either 3/4/5 as indicies.
	my $Family = $temp[$sortType];

	#the ID hash will containt the ID Number and the respective family this number belongs to.
	$IDhash{$primaryTemp[1]} = $Family;
}

close(READ);
#Get Annotation File from output of Bedtools Intersect between Reads and Index created from Index Script
#Contains all the reads in full length which overlapp a feature (ID)
my $annotationFile = "4169.Coverage.bed";

print "Output File name:\n";
my $outName = <STDIN>;
chomp $outName;
close($outName);

my $outFileName = "4169.".$outName.".Coverage.Expanded.bed";

open(READ2,$annotationFile) || die "Could not open $annotationFile!: $!";
open(OUTFILE,">",$outFileName) || die "Could not open outfile!: $!";

print "Converting IDs to families...\n";

#Reading annotation file
while (<READ2>) {
	chomp;
	my $line = $_;
	#Split line by tab
	my @temp = split("\t",$line);
	#The IDs of the the concatenated genome are stored in field 9 (0 based)
	my $ID = $temp[3];
	#If more then one ID are in the same line -> Split it up
	my @subID;

	#Seperators of multi-ID lines is "|"
	if ($ID =~ m/\|/g) {

		#Split multi-ID line by "|"
		@subID = split(/\|/,$ID);
		my @temp2;

		#First ID always starts with ":"
		if ($subID[0] =~ m/\:/g ){
			#So split this up aswell and replace the first ID in the Sub ID array
			#with the correctly formated "ID"
			@temp2 = split(/\:/,$subID[0]);
			#SubID[0] now contains the correct ID Number
			$subID[0] = $temp2[1];
		}
	#If it is a simple one ID sample, just remove the "ID:"
	}else{

		my @temp3 = split(/\:/,$ID);
		$subID[0] = $temp3[1];

	}

	#Test area
	foreach my $elements(@subID){

		if (exists $IDhash{$elements}) {

			print OUTFILE "$temp[0]\t$temp[1]\t$temp[2]\t$IDhash{$elements}\t$temp[7]\tID:$elements\n";
		}
	}

	foreach my $elements(@subID){

		if (exists $IDhash{$elements}) {

			my $familyName = $IDhash{$elements};

			if (exists $outHash{$familyName}){

				push( @{$outHash{$familyName}},$temp[7] );

			}else{

				$outHash{$familyName} = [$temp[7]];

			}
		}
	}
}



my $outPut = "4169.".$outName.".IDCoverage.FULL.bed";

open(OUTPUT,">",$outPut) || die "Could not create output file $outPut!: $!";


print "Processing Output...\n";

print "Choose type for output printing:\n0 - Row Wise\n1 - Colwise\nDefault - Row Wise\n";
my $pickType = <STDIN>;
chomp $pickType;

if ($pickType ne "") {

	if ($pickType == 0) {

		printRow(%outHash);

	}elsif($pickType == 1){

		printCol(%outHash);

	}

}else{

	printRow(%outHash);

}

print "Printing Output...\n";


sub printRow {

	my %hash1 = @_;

	my $i = 0;

	foreach my $keys(sort keys %hash1){
		print OUTPUT "$keys";

		for $i (0 .. $#{ $hash1{ $keys } } ) {
			print OUTPUT  ",$hash1{$keys}[$i]";
		}

		print OUTPUT  "\n";
	}
}


sub printCol{

	my %hash2 = @_;

	my @header = sort keys %hash2;

	print OUTPUT join (",", @header), "\n";
	while ( map {@$_} values %hash2 ) {
   	my @row;
  	push( @row, shift @{ $hash2{$_} } // '' ) for @header;
   	print OUTPUT join (",", @row ), "\n";
   }
}

close(OUTPUT);






print "Done\n";
my $stop = time();
my $jobTime = $stop - $start;
print "$jobTime\n";
