#!/usr/bin/perl

use warnings;
use strict;
use List::MoreUtils qw(uniq);
use Data::Dumper qw(Dumper);

my $InPut = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/GSM530651/SRR066153.trimmed.fastq";
my $outPut = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/GSM530651/SRR066153.ReadSeqs";

open(READ,$InPut) || die "Could not open $InPut! $!";
open(OUT,">",$outPut) || die "Could not open $outPut! $!";



while (<READ>) {
	chomp;
	my $line = $_;

	if ($line =~ /\@SRR/g) {
		
		my @temp = split(/\s/,$line);
		print OUT ">$temp[0]\n";

	}elsif($line =~ /^[ACTGN]+/g){

		print OUT "$line\n";
	}
}

print "Done!\n";