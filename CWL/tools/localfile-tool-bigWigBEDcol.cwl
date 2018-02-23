#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "YAP_MCSv3_bigWigBEDcol"
label: "YAP MCSv3 bigWigBEDcol"

cwlVersion: "v1.0"

doc: |
    converts a BED file to bigwig format

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström


requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $( inputs.scriptFolder )

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/ucsc-bedgraphtobigwig:357--1"

baseCommand: ["bash", "scripts/mergeBED"]

stdin: $( inputs.input )

outputs:
  bigwigFile:
    type: File
    outputBinding:
      glob: $( inputs.output_name )

inputs:

  input:
    type: File
    doc: |
      The BED file to be converted.

  chromSizeFile:
    type: File
    inputBinding:
      position: 5
      prefix: -s
    doc: |
      file containing chromosome sizes

  columnToUse:
    type: int
    inputBinding:
      position: 5
      prefix: -c
    doc: |
      column to extract and export in the bigwig file

  output_name:
    type: string
    doc: |
      Name of output file

  isZipped:
    type: boolean?
    inputBinding:
      position: 5
      prefix: -z
    doc: |
      set if the input file is compressed. Expects an 
      uncompressed file by default

  scriptFolder:
    type: Directory
    default:
      class: Directory
      location: ../../scripts
    doc: |
      folder containing associated scripts

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
