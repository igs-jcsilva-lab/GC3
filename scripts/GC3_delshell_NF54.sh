#!/bin/bash

#############################################################
######### Shell script for GC3 ############
#############################################################

### Author: Thomas Stabler, Msc (SwissTPH) with Ankit Dwivedi, PhD (IGS, UMSOM)
### Date: 04-12-2021

echo "STARTING SHELL SCRIPT..."

###############################################################################

echo "setting outputs and importing pathways"

set -o errexit
set -o nounset
set -o pipefail
set -o xtrace

###############################################################################
#Current paths defined for UMB servers. User will need to adjust if using on their own system

java="/usr/local/packages/jdk-8u151/bin/java"
#java="/usr/bin/java"

py="/usr/local/packages/python-3.8.2/bin/python3.8"
#py="/usr/bin/python3.6"

gatk="/usr/local/packages/gatk-4.0.4.0/gatk"
#gatk="/gatk/gatk"

#aux="/local/projects-t3/p_falciparum/auxiliary_files"

###############################################################################

#Variables to assign in terminal command line

folder=$1
path=$2
file=$3 # txt file name without extension
tag=$4

###############################################################################
echo "Make directory $path/$tag"
mkdir -p "$path"/"$tag"

###############################################################################

# get list of sample names
echo "Reading sample names"

samples=$(while read p; do echo "$p"; done <"$path"/"$folder"/"$file".txt)
echo $samples

#using for loop, extract BED coverage files for each sample using sample variable (list of sample directories); then for loop through sample directories to apply GC3
echo "Starting for loop..."
for i in $samples
do
	echo "Starting file processing..."
	label=$(echo $i | sed 's/\//_/g' | sed -e 's/.*samples_\(.*\)_alignments.*/\1/')
	echo $label
	#The below step (zcat) is optional. This subsets the larger coverage file and cuts down on run time of GC3. 
	zcat $i | awk '$1=="Pf3D7_08_v3" && $2>=1290240 && $2<=1443449' > "$path"/"$tag"/"$label"_tmp08
	zcat $i | awk '$1=="Pf3D7_08_v3" && $2>=2731041 && $2<=2892340' > "$path"/"$tag"/"$label"_tmp13
	#Steps below call GC3 command script with hrp2 and hrp3 parameters
	$py GC3_cmd.py -v "$path"/"$tag"/"$label"_tmp08 -s 1290240 -e 1443449 -m "Pf3D7_08_v3" -i 1000 -j 500 -f "window" -o "$path"/"$tag"/samples_coverage_chrm08.txt
	$py GC3_cmd.py -v "$path"/"$tag"/"$label"_tmp08 -s 1372236 -e 1377299 -m "Pf3D7_08_v3" -i 1 -j 1 -f "window" -o "$path"/"$tag"/samples_coverage_chrm08_zoom.txt
	$py GC3_cmd.py -v "$path"/"$tag"/"$label"_tmp08 -s 1290240 -e 1443449 -m "Pf3D7_08_v3" -f "mean" -o "$path"/"$tag"/chrm08_mean_cov.txt
	$py GC3_cmd.py -v "$path"/"$tag"/"$label"_tmp13 -s 2731041 -e 2892340 -m "Pf3D7_13_v3" -i 1000 -j 500 -f "window" -o "$path"/"$tag"/samples_coverage_chrm13.txt
        $py GC3_cmd.py -v "$path"/"$tag"/"$label"_tmp13 -s 2840727 -e 2841703 -m "Pf3D7_13_v3" -i 1 -j 1 -f "window" -o "$path"/"$tag"/samples_coverage_chrm13_zoom.txt
        $py GC3_cmd.py -v "$path"/"$tag"/"$label"_tmp13 -s 2731041 -e 2892340 -m "Pf3D7_13_v3" -f "mean" -o "$path"/"$tag"/chrm13_mean_cov.txt
	rm "$path"/"$tag"/"$label"_tmp*	
	echo "Completed samples $label"
done

echo "END SHELL SCRIPT"
