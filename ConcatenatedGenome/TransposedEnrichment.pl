#!/usr/bin/perl

use warnings;
use strict;
use List::MoreUtils qw(uniq);
use Data::Dumper qw(Dumper);

my $start = time();
my $current = 0;
my $InPut = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/Annotation/SuperFamily/4169.SuperFamilies.IDAnnotation.FULL.bed";

my $outPut = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/Annotation/SuperFamily/4169.SuperFamilies.EnrichedSpeciesByRead.bed";

my $outPutHeader = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/Annotation/SuperFamily/4169.HEADER.SuperFamilies.EnrichedSpeciesByRead.bed";

open(READ,$InPut) || die "Could not read $InPut: $!";

my %ReadFamily;
my @readsList;
my @famsList;
my $SampleName;

my $counter = 0;

print "Reading... \n";

while (<READ>) {

	chomp;
	my @temp = split("\t",$_);
	my $Read = $temp[3];


	my @temp2 = split(/\./,$Read);
	$Read = $temp2[1];
	$SampleName = $temp2[0];

	my $RepeatFamily = $temp[4];
	$ReadFamily{$Read}{$RepeatFamily} += 1;

}

#Memory 
foreach my  $readelement(keys %ReadFamily){
	push(@readsList,$readelement);
	foreach my $families ( keys %{$ReadFamily{$readelement}} ){
		push(@famsList,$families);
	}
}

print "Processing to CSV...\n";

my @uniqReads = uniq sort @readsList;
my @uniqFams = uniq sort @famsList;
@famsList = ();
@readsList = ();

my $i = 0;
my $j = 0;


open(OUTDUMP,">","Dumper");
print OUTDUMP Dumper \%ReadFamily;

open(OUTPUTFILE,">",$outPut) || die "Could not open Output File: $!";
open(OUTPUTHEADER,">",$outPutHeader) || die "Could not open header file: $!";


my $header = join("\t",@uniqFams);
print OUTPUTHEADER "$header";
print OUTPUTHEADER "\n";

$header = 0;

print "Printing output ... \n";

foreach my $reads (@uniqReads){

	print OUTPUTFILE "$reads";

	foreach my $fams(@uniqFams){

			if (exists $ReadFamily{$reads}{$fams}) {

			print OUTPUTFILE "\t$ReadFamily{$reads}{$fams}";
			delete $ReadFamily{$reads}{$fams};

		}else{

			print OUTPUTFILE "\t";
			delete $ReadFamily{$reads}{$fams};
		}

		$j++;

	}

	print OUTPUTFILE "\n";
	$j = 0;
	$i ++;
}

close(READ);
my $stop = time();
my $jobTime = $stop - $start;
print "Time: $jobTime\n";
