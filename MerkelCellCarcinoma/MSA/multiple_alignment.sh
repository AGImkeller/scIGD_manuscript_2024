#!/bin/bash

# Input and output files
input_file="sequences.fasta"  # Input FASTA file
output_file="aligned_sequences.aln"  # Output file in Clustal format

# Run Clustal Omega for MSA
echo "Running multiple sequence alignment using Clustal Omega..."
clustalo -i "$input_file" -o "$output_file" --outfmt=clu