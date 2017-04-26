#!/usr/bin/perl

use warnings;
use strict;
use List::MoreUtils qw(uniq);
use Data::Dumper qw(Dumper);

my $InPut = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/GSM530651/SRR066153.trimmed.fastq";
my $outPut = "/home/chrys/Documents/thesis/data/analysis/artificialGenome/GSM530651/SRR066153.Dummy.bed";

open(READ,$InPut) || die "Could not open $InPut! $!";
open(OUT,">",$outPut) || die "Could not open $outPut! $!";

my $start = 0;
my $stop = 0;
my $len = 0;
my $chr = "chrShuff";

print "Working...\n";

while (<READ>) {
	chomp;
	my $line = $_;
	#print "Working...\r";

	if ($line =~ /length=[0-9]+/) {
		
		my @temp = split(/\=/,$line);
		$len = $temp[1];

	}


	if ($line =~ /\@SRR/g) {

		print "Working...\r";
		my @temp = split(/\s/,$line);
		my $varTemp = $temp[0];
		$varTemp =~ s/@//;

		$stop += $len;

		print OUT "$chr\t$start\t$stop\t$varTemp\n";

		$start = $stop+1;

	}
}

print "Done!\n";