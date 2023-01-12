#!/bin/bash
#Script to calculate counting Bins, IT Spaanderman, 2021

#Get user variables or show usage message 
usage() { echo "Usage: $0 [-i GTF_FILE] [-g LIST_OF_GENES] [-o OUTPUT_FILENAME_PREFIX]" 1>&2; exit 1; }

while getopts ":i:g:o:" x; do
    case "${x}" in
        i)
            i=${OPTARG}
            ;;
        g)
            g=${OPTARG}
            ;;
        o)
            o=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${i}" ] || [ -z "${g}" ] || [ -z "${o}" ]; then
    usage
fi

#Make temporary directory for intermediate files
temp_dir="temp"
mkdir $temp_dir

#Function for each gene
countingBins(){
    #Create name variables
    local gene=$1
    genefile=$temp_dir"/"$gene".gtf"
    exonsfile=$temp_dir"/"$gene".exons.gtf"
    exonstartsfile=$temp_dir"/"$gene".exonsstart.tsv"
    exonstopsfile=$temp_dir"/"$gene".exonsstops.tsv"
    exonspositions=$temp_dir"/"$gene".exonspositions.tsv"
    genepositions=$temp_dir"/"$gene".positions.tsv"
    genecountingbins=$temp_dir"/"$gene".countingbins.tsv"
    genempileupregions=$temp_dir"/"$gene".mpileupregions.tsv"

    #Filter gtf
    grep -F -w $gene $i > $genefile
    grep -F "ENSE" $genefile > $exonsfile
    awk -F"\t" '{print $4}' $exonsfile | sort | uniq -u > $exonstartsfile
    awk -F"\t" '{print $5}' $exonsfile | sort | uniq -u > $exonstopsfile
    sed -i "s/$/\t0/" $exonstartsfile
    sed -i "s/$/\t1/" $exonstopsfile
    cat $exonstartsfile $exonstopsfile > $exonspositions
    sort -k1 -n $exonspositions > $genepositions

    #Calculate bins with Rscript
    Rscript ~/ResearchCloud/Ubuntu/Bins.R $genepositions $gene
    
    #Add chrom and gene name information to countingbins and mpileupregions
    chrom=$(awk 'FNR == 1 {print $1}' $exonsfile)
    sed -i "s/$/\t$chrom/" $genecountingbins
    sed -i "s/$/\t$gene/" $genecountingbins
    sed -i "s/$/\t$chrom/" $genempileupregions
    sed -i "s/$/\t$gene/" $genempileupregions

    #Remove temporary files except for countingbins and mpileup regions
    rm $genefile $exonsfile $exonstartsfile $exonstopsfile $exonspositions $genepositions
}

#Calculate counting bins for each gene
genefile=$g
readarray -t genes < $genefile

for gene in "${genes[@]}"
do
    countingBins $gene
done

#Merge files for all genes
find . -name "*.countingbins.tsv" -exec cat {} + > $o".countingbins.out"
find . -name "*.mpileupregions.tsv" -exec cat {} + > $o".mpileupregions.out"

#Remove temporary directory
rm -r $temp_dir