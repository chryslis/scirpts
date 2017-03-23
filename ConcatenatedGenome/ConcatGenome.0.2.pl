#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper qw(Dumper);

my $file = $ARGV[0];
my $outFile = "ConcatenatedGenome".$file;
my $spacerLength = $ARGV[1];
my %sequences;
my $chrom;
my $start;
my $spacer = "N" x $spacerLength;

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
	
	}
}

my %outHash;

foreach my $chroms (sort my_sort keys %sequences){
	
	foreach my $starts (sort keys %{ $sequences{$chroms} } ){

		$outHash{$chroms} .= $spacer.$sequences{$chroms}{$starts}.$spacer;
		
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


