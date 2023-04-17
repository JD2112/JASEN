#!/usr/bin/env bash
set -e

definitions=(chewbbaca postAlignQc resfinder virulencefinder pythonScripts)
declare -A containers=( 
    [bwa]=https://depot.galaxyproject.org/singularity/bwa:0.7.17--pl5.22.0_2
    [kraken2]=https://depot.galaxyproject.org/singularity/kraken2:2.1.2--pl5321h9f5acd7_3
    [bracken]=https://depot.galaxyproject.org/singularity/bracken:2.8--py39hc16433a_0
    [samtools]=https://depot.galaxyproject.org/singularity/samtools:1.17--h00cdaf9_0
    [ariba]=https://depot.galaxyproject.org/singularity/ariba:2.14.6--py39h8f06ca0_2
    [mlst]=https://depot.galaxyproject.org/singularity/mlst:2.23.0--hdfd78af_1 
    [spades]=https://depot.galaxyproject.org/singularity/spades:3.15.5--h95f258a_1
    [skesa]=https://depot.galaxyproject.org/singularity/skesa:2.4.0--he1c1bb9_0
    [quast]=https://depot.galaxyproject.org/singularity/quast:5.2.0--py310pl5321hc8f18ef_2
    [freebayes]=https://depot.galaxyproject.org/singularity/freebayes:1.3.6--hbfe0e7f_2
    [perl_json]=https://depot.galaxyproject.org/singularity/perl-json:4.10--pl5321hdfd78af_0
)

for tool in "${definitions[@]}"; do
    if [ $(grep -q "${tool^^}_VERSION=" "${tool}") ]; then
        version=$(grep "${tool^^}_VERSION=" "${tool}" | sed "s/.*=//")
    else
        version=$(grep "VERSION " "${tool}" | sed "s/.* //")
    fi;

    output_file="${tool}_${version}.sif";
    if [[ ! -f $output_file ]]; then
        echo "Building tool ${tool} to ${output_file}";
        sudo -E singularity build --force "${output_file}" "${tool}";
        ln -sf "${output_file}" "${output_file%%_*}.sif"
    else
        echo "Tool ${tool} already exist, skipping...";
    fi;
done;

echo "Download pre built singularity containers";
for tool in ${!containers[@]}; do
    version=$(echo "${containers[$tool]}" | sed -E "s/.*:|.*%//" | sed "s/--.*//")
    output_file="${tool}_${version}.sif";
    if [[ ! -f $output_file ]]; then
        echo "Downloading ${tool}";
        wget -O "${output_file}" "${containers[$tool]}" "--no-check-certificate"
        ln -sf "${output_file}" "${output_file%%_*}.sif"
    else
        echo "Tool ${tool} already exist, skipping...";
    fi;
done
