#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);

my $start = time();
my $timestamp = localtime();
my $file2 = $ARGV[0];

my $JobIDFile = $file2;
my @outPutName = split(/\./,$JobIDFile);
my $outName = $outPutName[0];

print "Input File: $JobIDFile\n";

if($JobIDFile =~ /([0-9]+)/g){
	$JobIDFile = $1;
}

print "JobID: $JobIDFile\n";


my $outFile =  $outName.".Merged.".$JobIDFile;
my $outReport = $outName.".Report.Merged.".$JobIDFile;

open(FH,$file2) || die "Could not open $file2: $!\n";
open(OUT,">",$outFile) || die "Could not create Output: $!\n";
open(OUTJOB,">",$outReport) || die "Could not create Output: $!\n";

$_ = <FH> or exit;

chomp;
my @sample = split;
my $sampleID = $sample[6];

while (<FH>) {
	chomp;
	my @newsample = split("\t",$_);
	my $newsampleID = $newsample[6];
	
	if ($sample[0] ne $newsample[0]  || $newsample[2] < $sample[1] || $sample[2] < $newsample[1]) {

		print OUT "$sample[0]\t$sample[1]\t$sample[2]\t$sample[6]\n";

		@sample = @newsample;
		$sampleID = $sample[6];
		
	}elsif ( $sample[1] <= $newsample[1] && $newsample[2] <= $sample[2] ){

		my $concat = $newsampleID;
		$concat =~ s/ID\:/\|/g;
		$sample[6] = $sample[6].$concat
		
	}elsif ( $sample[1] <= $newsample[1] ){

		my $concat = $newsampleID;
		$concat =~ s/ID\:/\|/g;
		$sample[2] = $newsample[2];
		$sample[6] = $sample[6].$concat;

	}elsif ($newsample[2] <= $sample[2] ){


		print "This should not happend!";
		$sample[1] = $newsample[1];

	}else{

		@sample = @newsample;
		$sampleID = $sample[6];

	}	
}

print OUT "$sample[0]\t$sample[1]\t$sample[2]\t$sample[6]\n";

my $end = time ();
my $jobTime = $end-$start;

print OUTJOB "Timestamp:$timestamp\nJob took $jobTime seconds\nJobID:$JobIDFile\n";

close(FH);
close(OUT);
close(OUTJOB);
