#!usr/bin/perl
use strict;
use warnings;
use Data::Dumper qw(Dumper);

#Record start time
my $start_run = time();
print "Starting ... \n";

my $dataBase = $ARGV[0];
my %repeats;

open(READ,$dataBase) || die "Could not open $dataBase: $!";

#Stuff
my $name;
my $superfamily;
my $localTime = gmtime();
$localTime =~ s/ /-/g;


#Loop to grab the descriptors of the repeats
while (<READ>) {
	chomp;
	
	if($_ =~ /^NAME\s+(\S+)/gi){
		$name = $1;
	}

	my $switch = 0;

	if($_ =~ /^CT\s+(Superfamily.+)/g){
		
		my @temp = split /\;/,$1;
		$superfamily = $temp[1];
		$superfamily =~ s/^\s+//;
		$switch = 1;

	}else{

		$switch = 0;

	}

#Sorting the database into a hash. 
#Hash saves the names as keys to a sub-hash attached to an array with detailed information.
	if ($switch != 0) {

		if (exists $repeats{$superfamily}){

			$repeats{$superfamily}{$name} = $name;
		
		}else{

			$repeats{$superfamily}{$name} = $name;
		}
	}
}

my $end_run = time();

close(READ);

my $run_time = $end_run-$start_run;
print "Database Indexing Job took $run_time seconds\n";
print "Accessing *.bed file to sort repeats \n";

$start_run = time();

#Input is a *.bed file 

my $repeatIndex = $ARGV[1];
my $outPutName = $ARGV[2];
my %Index;
my $counter = 0;



open(READ,$repeatIndex) || die "Could not read *.bed file: $repeatIndex. $!";
open(OUT,">",$outPutName.$localTime."SortOut.bed") || die "Could not create file! $!";


while (<READ>){

	chomp;
	my @temp = split(/\t/,$_);

	foreach my $keysSC( keys %repeats){

		foreach my $keysDatabse (%{$repeats{$keysSC}}){

			if ($keysDatabse eq $temp[3]) {

				print "Printing line $counter \n";

				print OUT join("\t",@temp)."\t".$keysSC."\n";				

			}
		}
	}

	$counter ++;
}


$end_run = time();
$run_time =$end_run-$start_run;

print "Done exit status 0\n";
print "Runtime for family sorting job was: $run_time\n";
close(OUT);