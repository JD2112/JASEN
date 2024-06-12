process create_yaml {
  tag "${sampleID}"
  scratch params.scratch

  input:
    tuple val(sampleID), path(prp), path(signature)
    val species

  output:
    tuple val(sampleID), path(output), emit: yaml

  script:
    def prpDir = task.ext.args_prp ?: ""
    def sourmashDir = task.ext.args_sourmash ?: ""
    output = "${sampleID}_bonsai.yaml"
    """
    #!/usr/bin/env python
    import yaml

    # Define the data
    data = {
        "group_id": "${species}",
        "prp_result": "${prpDir}/${prp}",
        "minhash_signature": "${sourmashDir}/${signature}"
    }

    # Write the data to the YAML file
    with open("$output", "w") as fout:
        yaml.dump(data, fout, default_flow_style=False)
    """

  stub:
    output = "${sampleID}_bonsai.yaml"
    """
    touch $output
    """
}
