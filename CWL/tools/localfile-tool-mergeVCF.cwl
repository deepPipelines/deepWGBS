#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "YAP_MCSv3_mergeVCF"
label: "YAP MCSv3 mergeVCF"

cwlVersion: "v1.0"

doc: |
    Merges VCF files by removing headers from all but the first file and concatenating.

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"


requirements:
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/YAP_MCSv3:0.0.1"

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000

baseCommand: ["mergeVCF"]

stdout: $( inputs.output_name )

outputs:
  mergedVCF:
    type: stdout

inputs:

  input:
    type:
      type: array
      items: File
    inputBinding:
      position: 5
    doc: |
      The file to be adjusted.

  output_name:
    type: string
    doc: |
      Name of output file

