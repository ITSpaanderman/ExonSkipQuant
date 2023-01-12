#!/bin/bash
#Script to calculate Samtools Mpileup for counting Bins, IT Spaanderman, 2021

#Get user variables or show usage message 
usage() { echo "Usage: $0 [-r REGIONS_FILE] [-b DIRECTORY WITH BAM FILES] [-o OUTPUT_DIR]" 1>&2; exit 1; }

while getopts ":r:b:o:" x; do
    case "${x}" in
        r)
            r=${OPTARG}
            ;;
        b)
            b=${OPTARG}
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

if [ -z "${r}" ] || [ -z "${b}" ] || [ -z "${o}" ]; then
    usage
fi

#Make output directory for mpileup files
mkdir $o
echo "output directory created"

#Create array with regions from regions file
readarray -t regionsInfo < $r
regionArray=()
echo "start parsing regions"

for regionInfo in "${regionsInfo[@]}"
    do
        infoArray=($regionInfo)
        regionStart="${infoArray[0]}"
        regionStop="${infoArray[1]}"
        regionChrN="${infoArray[2]}"
        region="chr"$regionChrN":"$regionStart"-"$regionStop
        regionArray+=($region)
    done
echo "regions parsed"

#Get all bamfiles in directory save as txt file and use in mpileup analysis for each region
bam_dir=$b
find $b -name "*.bam" > bamFiles.txt
    for reg in "${regionArray[@]}"
        do 
            # Calculate mpileup for each region
            echo -e  "\\rstrart samtools for $reg"
            samtools mpileup -b bamFiles.txt -r $reg -o $o"/"$reg".mpileup.out"
    done
                
echo "all mpileup results finished"




    

