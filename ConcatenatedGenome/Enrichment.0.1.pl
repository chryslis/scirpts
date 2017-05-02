#!/usr/bin/perl

use warnings;
use strict;
use List::MoreUtils qw(uniq);
use Data::Dumper qw(Dumper);

my $start = time();
my $current = 0;
#my $InPut = "/home/chrys/Documents/thesis/data/scripts/ConcatenatedGenome/4169.IDAnnotation.FULL.bed";
my $InPut = "/home/chrys/Documents/thesis/data/scripts/ConcatenatedGenome/test500";

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
	$ReadFamily{$RepeatFamily}{$Read} += 1;

}

#Memory 
foreach my $families(keys %ReadFamily){
	push(@famsList,$families);
	foreach my $readelements ( keys %{$ReadFamily{$families}} ){
		push(@readsList,$readelements);
	}
}

print "Processing to CSV...\n";

#my @outMatrix;
my @uniqReads = uniq sort @readsList;
my @uniqFams = uniq sort @famsList;
@famsList = ();
@readsList = ();

my $i = 0;
my $j = 0;

open(TEST,">","test500row");

my $header = join(",",@uniqReads);
print TEST "$header";
print TEST "\n";
$header = 0;

foreach my $fams (@uniqFams){

	print TEST "$fams";

	foreach my $reads (@uniqReads){

		if (exists $ReadFamily{$fams}{$reads}) {
			
			print TEST ",$ReadFamily{$fams}{$reads}";
			#$outMatrix[$i][$j] = $ReadFamily{$fams}{$reads};
			delete $ReadFamily{$fams}{$reads};

		}else{

			print TEST ",0";
			#$outMatrix[$i][$j] = 0;
			delete $ReadFamily{$fams}{$reads};
		}

		$j++;
	}

	print TEST "\n";
	$j = 0;
	$i ++;
}

close(READ);
my $stop = time();
my $jobTime = $stop - $start;
print "Time: $jobTime\n";

#print Dumper \@uniqFams;