#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "YAP_MCSv3_getChrName"
label: "YAP MCSv3 getChrName"

cwlVersion: "v1.0"

doc: |
    Merges VCF files by removing headers and concatenating.

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
    dockerPull: "quay.io/biocontainers/samtools:1.3.1--5"


baseCommand: ["bash", "scripts/getChrName"]

stdout: $( inputs.output_name )

outputs:
  chrNames:
    type: stdout

inputs:

  input:
    type: File
    inputBinding:
      position: 10
      prefix: -i
    doc: |
      Bam file from which to extract names

  output_name:
    type: string
    doc: |
      Name of output file

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
