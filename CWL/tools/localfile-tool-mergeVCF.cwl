#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "YAP_MCSv3_mergeVCF"
label: "YAP MCSv3 mergeVCF"

cwlVersion: "v1.0"

doc: |
    Merges VCF files by removing headers from all but the first file and concatenating.

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
    dockerPull: "quay.io/biocontainers/bis-snp-utils:0.0.1--pl5.22.0_0"

baseCommand: ["bash", "scripts/mergeVCF"]

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
