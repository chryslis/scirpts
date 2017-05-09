State of the Pipeline on 9.5.2017

The pipeline is built into serveral pieces.
The first one part is the construction of the concatenated genome, which includes sorting and cleaning.
It removes several different types of repeats as well as assigns IDs to elements.



1.Create a Indexed File

Script: artificalGenome.0.2.pl
Input: RepeatMasker Track File
Requirements: First line in a RepeatMaskerTrack is a header,remove it. Sort the file, first by chromosome then by legnth of the features. If it is a standard bed file use sort -k1,1 -k2,2n.
Functions: Indexing and removing unwanted types of repeats.
Outputs: Indexed File and a Report with an assgined jobID. It is recommended to use the jobID for further anaylsis to keep an clear overview of the progress.



2.Merge Overlapping Features

Script: Merger.0.2.pl
Input: Output from first script, or an indexed RepeatMasker Track. 
First argument: Output from previous script.
Second argument: Number for outputfile,preferably the jobID from #1.
Requirements: Correct Output of the previous script. No more poresscing necessary.
Functions: Merges overlapping features and IDs.
Outputs: Merged file. Multiple IDs are stored like : IDx|y|z



2.1.Index from Merge

Script: IndexfromMerge
Input: Output from #2 and a Spacer length
First argument: Outputfile 2.1
Second argument: Spacer length - default should be 350
Requirments: Check with what chromosome the file starts, if chr1 is not the first chromosome change this in the script.
Function: Creates and Index of the merged repeats which may be viewed in IGV
Ouputs: Index file, which stores the IDs and the positions of the features in the new file.



3. Get fasta sequences for the features.

Script: BedtoolsGetfasta
Input: Outputfile from #2. Holds the original genomic locations.
Output: Fasta-file of all genomic locations



4.Concatenate Genome

Script:ConcatGenome.0.2.pl
Input: Fasta file with the appropriate genomic locations. 
First argument: Fasta file
Second argument: Spacer length for construction. Default should be 350
Requirments: No special requirments.
Output: Genome file with the structure NNNNNNNNNNAGCTGCGCGCGCNNNNNNNNN



5. Read Aligment

If only *.sra files are availble:
fastq-dump *.sra

Script / Aligner: Recommended to use bwa
Input: Reads of a given dataset. Do quality control before hand. Ensure that reads are properly trimmed and cleaned for k-mer bias. Input as genome is the fasta file created before hand.
Example command for bwa:
bwa mem -a -t 3  InputFile 



6. Create bed file

Use bedtools to create a bed file from bam.
Command should be bamtobed.
The reads which were aligned, can now be interesected with the index file from the merger.
Use settings as you wish, but both, Input and Output Feature locations must be written.

Example:
bedtools intersect -wo -a Reads.sorted -b Index
Note:
This will ignore any fractional overlapp if not specified.



7. ID Expanding and Sorting - IDAnnotationSort/IDCoverageSort
Script: IDAnnotationSort.0.1.pl / IDCoverageSort.0.1.pl

IDAnnotationSort
First argument: At this point, not accessible. But should be the intersected file from #6.
Output: Expanded File with classes / features assigned to reads

IDCoverageSort
Use this script for pure coverage. Meaning that in this case only the overlapp of reads over non 0 coverage nucleotides gets calcuated over a given feature.
Get the file from bedtools coverage



7.1 Calculate Read Enrichment per Feature

Script: Enrichment.0.2.pl
Input: IDAnnotationSort Output
Output: Matrix: Feature x Reads
First argument: File which contains counts for the specified inputs.
Requirments: No special requirements.
Output: Matrix feature x reads + file which stores the header if so wished.



7.2 Calculate Coverage per Nucleotide

INDEX=/home/chrys/Documents/thesis/data/analysis/artificialGenome/4169.BedIndexFromMerge.bed
Attention! File is gets very large.
Index is the original index from merging.

bedtools coverage -sorted -d -a INDEX -b READS > CovergaePerNuc.bed

Output may be further processed, by using CoveragePerNucleotide.pl script
Inputs: Output from 7.1
Output: Average coverage of the average read deapth per feature per nucleotide 
Requirement: None special.



