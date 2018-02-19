#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "YAP_MCSv3_mergeBED"
label: "YAP MCSv3 mergeBED"

cwlVersion: "v1.0"

doc: |
    Merges VCF files by removing headers and concatenating.

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

baseCommand: ["mergeBED"]

stdout: $( inputs.output_name )

outputs:
  mergedBED:
    type: stdout

inputs:

  sample_name:
    type: string
    inputBinding:
      position: 5

  input:
    type:
      type: array
      items: File
    inputBinding:
      position: 10
    doc: |
      The file to be adjusted.

  output_name:
    type: string
    doc: |
      Name of output file

