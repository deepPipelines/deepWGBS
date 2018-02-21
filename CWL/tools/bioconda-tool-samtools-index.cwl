#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "samtools_index"
label: "samtools index"

cwlVersion: "v1.0"

doc: |
    A Docker container containing samtools index. See the [htslib](http://www.htslib.org/) webpage for more information.

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"


requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: input
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/samtools:1.3.1--5"

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000

baseCommand: ["samtools", "index"]

outputs:
  indexedBam:
    type: File
    secondaryFiles:
      - ".bai"
    outputBinding:
      glob: $( inputs.input )

inputs:

  input:
    type: File
    inputBinding:
      position: 10

  interval:
    type: int?
    inputBinding:
      position: 5
      prefix: "-m"
    doc: |
      Set minimum interval size for CSI indices to 2^INT [14]

  csi:
    type: boolean?
    inputBinding:
      position: 5
      prefix: "-c"
    doc: |
      Generate CSI-format index for BAM files

  bai:
    type: boolean?
    inputBinding:
      position: 5
      prefix: "-b"
    doc: |
      Generate BAI-format index for BAM files [default]








