process RMATS_POST {
    tag "$meta.id"
    label 'process_single'

    container "${workflow.containerEngine in ['singularity', 'apptainer'] && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/rmats:4.3.0--py311hf2f0b74_5'
        : 'quay.io/biocontainers/rmats:4.3.0--py311hf2f0b74_5'}"

    // NOTES - post seems to need only the BAM *names*, not the actual files. Could we just get the first line of each file to get the names?
    // for file in `ls multi_bam_rmats_prep_tmp/*.rmats`; do head -1 $file; done | tr '\n' ','
    // possible suggestions from @SPPearce - pass ${prefix}.prep.b1.txt as outut
    // NOTES - for stats, it should be possible to parse the formula using patsy, but if we include PAIRADISE we might have R - just do this in R, first pass

    input:
    tuple val(meta), path(rmats_files)
    tuple val(meta2), path(reference_gtf)
    val read_length

    output:
    tuple val(meta), path("${prefix}_rmats_post"), emit: post_dir
    tuple val(meta), path("${prefix}.post.b1.txt"), emit: post_file_list
    tuple val("${task.process}"), val('rmats'), eval('rmats.py --version | sed -e "s/v//g"'), emit: versions_rmats, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: Where possible, a command MUST be provided to obtain the version number of the software e.g. 1.10
    //               If the software is unable to output a version number on the command-line then it can be manually specified
    //               e.g. https://github.com/nf-core/modules/blob/master/modules/nf-core/homer/annotatepeaks/main.nf
    //               Each software used MUST provide the software name and version number in the YAML version file (versions.yml)
    // TODO nf-core: It MUST be possible to pass additional parameters to the tool as a command-line string via the "task.ext.args" directive
    // TODO nf-core: If the tool supports multi-threading then you MUST provide the appropriate parameter
    //               using the Nextflow "task" variable e.g. "--threads $task.cpus"
    // TODO nf-core: Please replace the example samtools command below with your module's command
    // TODO nf-core: Please indent the command appropriately (4 spaces!!) to help with readability ;)
    // NOTES   --readLength READLENGTH
    //                    The length of each read. Required parameter, with the
    //                    value set according to the RNA-seq read length
    //          I should change it by read length (in workflow)! Look at Samtools stats!

    // NOTES for post - post requires the rmats files to be in the tmp directory, otherwise it fails
    """
    mkdir ${prefix}_rmats_tmp

    for file in ${rmats_files}
        do head -1 "\$file";
        cp "\$file" ${prefix}_rmats_tmp
    done | tr '\n' ',' > ${prefix}.post.b1.txt

    rmats.py \\
        --task post --statoff \\
        ${args} \\
        --nthread ${task.cpus} \\
        --b1 ${prefix}.post.b1.txt \\
        --gtf ${reference_gtf} \\
        --readLength ${read_length} \\
        --tmp ${prefix}_rmats_tmp \\
        --od ${prefix}_rmats_post
    """

    stub:
    def args = task.ext.args ?: ''
    prefix = task.ext.prefix ?: "${meta.id}"
    // TODO nf-core: A stub section should mimic the execution of the original module as best as possible
    //               Have a look at the following examples:
    //               Simple example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bcftools/annotate/main.nf#L47-L63
    //               Complex example: https://github.com/nf-core/modules/blob/818474a292b4860ae8ff88e149fbcda68814114d/modules/nf-core/bedtools/split/main.nf#L38-L54
    // TODO nf-core: If the module doesn't use arguments ($args), you SHOULD remove:
    //               - The definition of args `def args = task.ext.args ?: ''` above.
    //               - The use of the variable in the script `echo $args ` below.
    """
    echo $args

    touch ${prefix}.post.b1.txt
    mkdir ${prefix}_rmats_post
    touch ${prefix}_rmats_post/fromGTF.SE.txt
    touch ${prefix}_rmats_post/fromGTF.A3SS.txt
    touch ${prefix}_rmats_post/fromGTF.A5SS.txt
    touch ${prefix}_rmats_post/fromGTF.RI.txt
    touch ${prefix}_rmats_post/fromGTF.MXE.txt
    touch ${prefix}_rmats_post/JC.raw.input.SE.txt
    touch ${prefix}_rmats_post/JC.raw.input.A3SS.txt
    touch ${prefix}_rmats_post/JC.raw.input.A5SS.txt
    touch ${prefix}_rmats_post/JC.raw.input.RI.txt
    touch ${prefix}_rmats_post/JC.raw.input.MXE.txt
    touch ${prefix}_rmats_post/JC.raw.input.SE.txt
    touch ${prefix}_rmats_post/JC.raw.input.A3SS.txt
    touch ${prefix}_rmats_post/JC.raw.input.A5SS.txt
    touch ${prefix}_rmats_post/JC.raw.input.RI.txt
    touch ${prefix}_rmats_post/JC.raw.input.MXE.txt
    touch ${prefix}_rmats_post/JCEC.raw.input.SE.txt
    touch ${prefix}_rmats_post/JCEC.raw.input.A3SS.txt
    touch ${prefix}_rmats_post/JCEC.raw.input.A5SS.txt
    touch ${prefix}_rmats_post/JCEC.raw.input.RI.txt
    touch ${prefix}_rmats_post/JCEC.raw.input.MXE.txt
    """
}
