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
my $type;
my $class;
my $superfamily;


#Loop to grab the descriptors of the repeats
while (<READ>) {
	chomp;
	
	if($_ =~ /^NAME\s+(\S+)/gi){
		$name = $1;
	}

	
	if($_ =~ /^CT\s+(Type.+)/g){
		
		my @temp = split /\;/,$1;
		$type = $temp[1];
		$type =~ s/^\s+//;
	}

	if($_ =~ /^CT\s+(Class.+)/g){
		
		my @temp = split /\;/,$1;
		$class = $temp[1];
		$class =~ s/^\s+//;
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

#open(OUT,">","dumper.txt") || die "Could not create file $! \n!";
#print OUT Dumper \%repeats;

close(READ);

my $run_time = $end_run-$start_run;
print "Database Indexing Job took $run_time seconds\n";
print "Accessing *.bed file to sort Repeats \n";

$start_run = time();

#Input is a *.bed file 

my $repeatIndex = $ARGV[1];
#my $repeatIndex = "hg19RepeatsOverlappNoDup";
my %Index;

open(READ,$repeatIndex) || die "Could not read *.bed file: $repeatIndex. $!";

while (<READ>) {

	chomp;
	my @temp = split(/\t/,$_);
	my $featureLength = $temp[2] - $temp[1];

	if (exists $Index{$temp[3]}) {

		$Index{$temp[3]} += $featureLength;
	
	}else{

		$Index{$temp[3]} = $featureLength; 

	}
	

}

my $localTime = gmtime();
my $result = "result: ".$localTime.".txt";

open(OUT,">",$result) || die "Could not create file $! \n!";


my %results;

foreach my $superFam(keys %repeats){
	
	foreach my $repsDB (keys %{$repeats{$superFam}} ){

		foreach my $foundRep(keys %Index){

			if ($foundRep eq $repsDB) {
				
				if (exists $results{$superFam}) {
					
					$results{$superFam} += $Index{$foundRep};

				}else{

					$results{$superFam} = $Index{$foundRep};
				}
			}
		}
	}
}

$end_run = time();
$run_time = $end_run-$start_run;

print "Family sorting job did take $run_time seconds\n";


my $sum = 0;
foreach my $key(sort keys %results){
	print OUT "$key\t$results{$key}\n"; 
	$sum += $results{$key};

}

print "Done!\n";
print "$sum\n";
close(OUT);
close(READ);
