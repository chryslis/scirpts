#!/usr/bin/perl

use warnings;
use strict;
use List::MoreUtils qw(uniq);
use Data::Dumper qw(Dumper);

my $start = time();
my $current = 0;
my $outPut = "/home/chrys/Documents/thesis/data/scripts/ConcatenatedGenome/ExampleSample";
#my $outPut = "/home/chrys/Documents/thesis/data/scripts/ConcatenatedGenome/test.set";

open(READ3,$outPut) || die "Could not read $outPut: $!";

my %ReadFamily;
my @readsList;
my @famsList;

my $counter = 0;

while (<READ3>) {

	chomp;
	my @temp = split("\t",$_);
	#Carefull changed for example input original bed value is 3
	my $Read = $temp[0];
	#my $Read = $temp[3];
	#Carefull changed for example input original bed value is 4
	my $RepeatFamily = $temp[1];
	#my $RepeatFamily = $temp[4];

	push(@readsList,$Read);
	push(@famsList,$RepeatFamily);

	$ReadFamily{$RepeatFamily}{$Read} += 1;

	my $percentage = int(($counter/193925332)*100);
	print "Printing line $percentage %";
	print "\r";
	$counter ++;

}

print "\n";

my @outMatrix;

my @uniqReads = uniq sort @readsList;
my @uniqFams = uniq sort @famsList;

my $i = 0;
my $j = 0;

foreach my $fams (@uniqFams){

	foreach my $reads (@uniqReads){

		if (exists $ReadFamily{$fams}{$reads}) {
			
			my $value = $ReadFamily{$fams}{$reads};

			$outMatrix[$i][$j] = $value;

		}else{

			$outMatrix[$i][$j] = 0;
		}

		$j++;


	}

	$j = 0;
	$i ++;

}

open(OUTPUTFILE,">","OutputTest");

my $header = join("\t",@uniqReads);

print OUTPUTFILE "$header";
print OUTPUTFILE "\n";

for (my $t = 0; $t <= $#outMatrix; $t++) {

	print OUTPUTFILE "$uniqFams[$t]\t";

	for (my $x = 0; $x <= $#{$outMatrix[$t]}; $x++) {

		print OUTPUTFILE "$outMatrix[$t][$x]\t"; 
	}

	print OUTPUTFILE "\n";
}



print "\n";
my $stop = time();
my $jobTime = $stop - $start;
open (OUTDUMP,">","OutDump.txt");
print "Time: $jobTime\n";

print Dumper \%ReadFamily;
print "\n";
print Dumper \@uniqReads;