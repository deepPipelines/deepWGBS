#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "bioconda_piped_bgzip"
label: "bioconda piped bgzip"

cwlVersion: "v1.0"

doc: |
    block compression

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström


requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/tabix:0.2.5"

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

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
