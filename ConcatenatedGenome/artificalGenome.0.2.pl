#!/usr/bin/perl 

use strict;
use warnings;
use Data::Dumper qw(Dumper);

#requieres input to be sorted by chromosome and length
#use sort -k1,1 -k2,2n for bed files

my $start = time();
my $file = $ARGV[0];
my $rand = int(rand(10000));
my $outBedFile = $file.".indexed.".$rand;
my $jobID = $rand;
my $report = "Index-Report.".$rand;
my $timestamp = localtime();
my $oldcurrent = 0;
my $current = 0;

print "Starting up...\n";

open(READ,$file) || die "Could not open the file:$file because:$!\n";
open(OUTBED,">",$outBedFile) || die "Could not create $outBedFile:$!\n";
open(OUTJOB,">",$report) || die "Could not create $report:$!\n";

#ID for features
my $idNum = 0;

print "Processing...\n";
while (<READ>) {
	chomp;
	my $line = $_;
	$line =~ s/\s/\t/g;

	#Class Identifier is stored at pos12 / genomeStart = 7, Genome
	my @temp = split("\t",$line);
	#Make exclusion list accessible for user later
	#This is really crude and servers only as a placeholder until a more userfriendly
	#Interface can be implemented.
	if ($temp[12] eq "Low_complexity" || $temp[12] eq "Simple_repeat" || $temp[12] eq "Satellite" ) {
		next;
	}elsif($temp[11] eq "Satellite"){
		next;
	}elsif($temp[5] =~ /chr.+_/g ) {
		next;
	}elsif($temp[5] =~ /chrM/g ) {
		next;
	}else{
		#Generating intermediate file for storage of sequences.
		my $localTemp = $temp[5]."\t".$temp[6]."\t".$temp[7]."\t".$temp[10]."\t".$temp[11]."\t".$temp[12]."\t"."ID:$idNum";
		print OUTBED "$localTemp\n";
		$idNum++;
	}

	$oldcurrent = $current;
	$current = time();
	$current = int($current) - int($start);

	unless ($current == $oldcurrent){
		print "Current runtime: $current seconds";
		
	}

	print "\r";
}

print "\n";
my $end = time ();
my $jobTime = $end-$start;
print "Done, JobID:$rand\n";
print OUTJOB "Timestamp:$timestamp\nJob took $jobTime seconds\nJobID:$rand\n";

close(OUTJOB);
close(OUTBED);
close(READ);

my $exit_code;

exit $jobID;
