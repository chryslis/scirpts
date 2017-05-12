#!/bin/bash

PERL=/home/chrys/Documents/thesis/data/seqs/SuperFamilyFasta/GetStats.pl


for i in *.fasta; do

        echo ${i}

        $PERL "$i"

done
