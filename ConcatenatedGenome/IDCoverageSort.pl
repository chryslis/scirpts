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
my %outHash2;

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
	my $Family = $temp[3];

	#the ID hash will containt the ID Number and the respective family this number belongs to.
	$IDhash{$primaryTemp[1]} = $Family;
}

close(READ);
#Get Annotation File from output of Bedtools Intersect between Reads and Index created from Index Script
#Contains all the reads in full length which overlapp a feature (ID)
my $annotationFile = "4169.Coverage.bed";
#my $annotationFile = "test50";


open(READ2,$annotationFile) || die "Could not open $annotationFile!: $!";

my $outPut = "4169.IDCoverage.FULL.bed";
open(OUTPUT,">",$outPut) || die "Could not create output file $outPut!: $!";

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

	foreach my $elements(@subID){

		

		if (exists $IDhash{$elements}) {

			my $familyName = $IDhash{$elements};

			if (exists $outHash{$familyName}){

				push( @{$outHash{$familyName}},$temp[7] );

			}else{

				$outHash{$familyName} = [$temp[7]];

			}

			if (exists $outHash2{$familyName}){

				my $familyName = $IDhash{$elements};

				push( @{$outHash2{$familyName}},$temp[4] );

			}else{

				$outHash2{$familyName} = [$temp[4]];

			}

		}
	}
}

open (OUTPUT2,">","4169.IDReadCount") || die "Could not create second output!";

print "Processing Output...\n";

my @header = sort keys %outHash;

print OUTPUT join (",", @header), "\n";
while ( map {@$_} values %outHash ) {
   my @row;
   push( @row, shift @{ $outHash{$_} } // '' ) for @header;
   print OUTPUT join (",", @row ), "\n";
}

close(OUTPUT);

my @header2 = sort keys %outHash2;

print OUTPUT2 join (",", @header2), "\n";
while ( map {@$_} values %outHash2 ) {
   my @row;
   push( @row, shift @{ $outHash2{$_} } // '' ) for @header2;
   print OUTPUT2 join (",", @row ), "\n";
}



print "Done\n";
my $stop = time();
my $jobTime = $stop - $start;
print "$jobTime\n";
close(READ2);
close(OUTPUT);

my $i = 0;
my $j = 0;
my @outMatrix;




sub test {
for my $keys(sort keys %outHash){

	$outMatrix[$i] = $keys;

	for (my $t = 0; $t < scalar @{$outHash{$keys}}; $t++){
		
		$outMatrix[$i][$t] = $outHash{$keys}[$t];

	}

	$i++;
}
}
