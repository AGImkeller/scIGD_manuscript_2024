#!/bin/bash

# Input and output files
fasta_file="sequences.fasta"  # Input FASTA file
output_file="pairwise_similarity.txt"  # Output file for similarity percentages

# Initialize output file with a header
echo -e "Seq1\tSeq2\tSimilarity(%)" > "$output_file"

# Function to run needle on two sequences and extract the similarity percentage
run_needle() {
    seq1_file="$1"
    seq2_file="$2"
    output_file="$3"

    needle -asequence "$seq1_file" -bsequence "$seq2_file" -gapopen 10 -gapextend 0.5 -outfile "$output_file" -auto

    # Extract the similarity percentage from needle output
    similarity=$(grep -m 1 "^# Identity:" "$output_file" | awk '{print $4}' | tr -d '()%')
    echo "$similarity"
}

# Extract each sequence into a separate FASTA file and get its header
mkdir -p temp_sequences
declare -A sequence_names  # To store sequence file names and headers

# Loop through each sequence in the FASTA file
awk '/^>/{if(f) close(f); f="temp_sequences/seq" ++d ".fasta"; print > f; next} {print > f}' "$fasta_file"

# Associate each file with its header
index=1
while read -r line; do
    if [[ $line == ">"* ]]; then
        header=${line#>}
        sequence_names["temp_sequences/seq${index}.fasta"]="$header"
        index=$((index + 1))
    fi
done < "$fasta_file"

# Get all the sequence files generated
sequence_files=(temp_sequences/*.fasta)

# Perform pairwise alignment on each unique pair of sequences
for ((i=0; i<${#sequence_files[@]}; i++)); do
    for ((j=i+1; j<${#sequence_files[@]}; j++)); do
        seq1_file="${sequence_files[i]}"
        seq2_file="${sequence_files[j]}"
        temp_output="temp_alignment.txt"

        # Run needle and get the similarity percentage
        similarity=$(run_needle "$seq1_file" "$seq2_file" "$temp_output")

        # Extract sequence IDs from headers
        seq1_id="${sequence_names[$seq1_file]}"
        seq2_id="${sequence_names[$seq2_file]}"

        # Write the result to the output file
        echo -e "${seq1_id}\t${seq2_id}\t${similarity}" >> "$output_file"
        echo "Aligned $seq1_id and $seq2_id: Similarity = $similarity%"
    done
done

# Clean up temporary files
rm -rf temp_sequences temp_alignment.txt