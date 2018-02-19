#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "bioconda_piped_bgzip"
label: "bioconda piped bgzip"

cwlVersion: "v1.0"

doc: |
    block compression

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"


requirements:
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/tabix:0.2.5"

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000

baseCommand: ["bgzip", "-c"]

stdin: $( inputs.input )
stdout: $( inputs.output_name )

outputs:
  bgzippedFile:
    type: stdout

inputs:

  input:
    type: File
    doc: |
      The file to compress

  output_name:
    type: string
    doc: |
      Name of output file

