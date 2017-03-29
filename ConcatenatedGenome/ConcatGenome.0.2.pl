#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);

my $counter = 0;

my $file = $ARGV[0];

my $spacerLength = $ARGV[1];
my %sequences;
my $chrom;
my $start;
my $spacer = "N" x $spacerLength;

my $JobIDFile = $file;
my @outPutName = split(/\./,$JobIDFile);
my $outName = $outPutName[0];

print "Input File: $JobIDFile\n";

if($JobIDFile =~ /([0-9]+)/g){
	$JobIDFile = $1;
}else{
	$JobIDFile = "TEST";
}

print "JobID: $JobIDFile\n";

my $outFile = "ConcatenatedGenome.".$outName.".".$JobIDFile;

print "Creating Output: $outFile\n";

open(READ,$file) || die "Could not open $file: $!";
open(OUT,">",$outFile) || die "Could not create $outFile: $!";

while (<READ>) {
	chomp;
	if ($_ =~ /^>/g) {

		my @temp;
		@temp = split(":",$');
		$chrom = $temp[0];
		@temp = split("-",$temp[1]);
		$start = $temp[0];


	}else{

		my $seqData;
		$seqData = $seqData.$_;
	    $sequences{$chrom}{$start} .= $seqData;

	    $counter ++;

	    #if ($counter == 50) {
	    #	last;
	    #}
	
	}
}


my %outHash;

foreach my $chroms (sort my_sort keys %sequences){
	
	foreach my $starts (sort {$a <=> $b} keys %{ $sequences{$chroms} } ){;

		$outHash{$chroms} .= $spacer.$sequences{$chroms}{$starts};
		
	}
}


foreach my $chroms(sort my_sort keys %outHash){

	print OUT ">$chroms\n$outHash{$chroms}\n";

}

sub my_sort {

   my ($a1) = $a =~ m/chr(\w+)/;
   my ($b1) = $b =~ m/chr(\w+)/;

   if ( $a1 =~ /\d/ and $b1 =~ /\d/ ) {

      return $a1 <=> $b1;

   }else{

      return $a1 cmp $b1;

   }
}

my $timestamp = localtime();
my $report = $outName."Report";

open(REPORT,">",$report) || die "Could not create $report: $!";

print REPORT "Timestamp:$timestamp\nJobID:$JobIDFile\nSpace length used:$spacerLength\n";
#print REPORT Dumper \%outHash;

close(OUT);
close(READ);
close(REPORT);

