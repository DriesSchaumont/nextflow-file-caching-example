#!/usb/bin/env nextflow
nextflow.enable.dsl=2

params.asset_size = null

process foo {
    tag "${name}"
    debug true
    cpus 1
    memory 500.MB
    container "opensuse/leap:latest"
    input:
        val(name)
        path(asset_dir, stageAs: "test_assets")
    output:
        path("${name}.txt")
    """
    sha1sum ${asset_dir}/template.txt
    cat ${asset_dir}/template.txt > ${name}.txt
    echo ${name} >> ${name}.txt
    """
}

workflow {
    names = Channel.from(['Riri', 'Fifi', 'Loulou'])
    if (params.asset_size == "small") {
        asset_dir = file("${projectDir}/assets_small")
    } else if (params.asset_size == "large"){ 
        asset_dir = file("${projectDir}/assets")
    } else {
        error "ERROR: Please set params.asset_size to 'small' or 'large'"
    } 
    foo(names, asset_dir)
}
