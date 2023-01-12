# ExonSkipping
Repository containing methods to calculate skipping counts transcript specific regions. Belonging to the following manuscript:
### Neojunctions in Mismatch Repair Deficient Colorectal Cancer are Unrelated to FS-Indels and Immunologically of Limited Importance
#### I.T. Spaanderman, F.S. Peters, C. Tromedjo, O.J.A. Figaroa and A.D. Bins

<br />
## Prerequisites
- Linux/WSL/MacOs
- GTF file spanning the full genome including transcript level information
- List containing genes of interest (or all genes)
- R (tested on version 4.2.1)
- Samtools

## Usage
1. Run CountingBins.sh to create counting bins for specified list of genes
````bash
./CountingBins.sh \
-i GTF_FILE \
-g ARRAY OF GENES \
-o OUTPUT_REGIONS_FILE
````
2. Create mpileup skipping counts for counting bins for sequencing files
````bash
./SkipMpileup.sh \
-r INPUT_REGIONS_FILE \
-b DIRECTORY_CONTAINING_BAM_FILES \
-o OUTPUT_DIRECTORY
````
3. Downstream analysis of skipping counts for each region for each .bam file
