#!/usr/bin/env cwl-runner

class: ExpressionTool

id: "YAP_MCSv3_loadlines"
label: "YAP MCSv3 loadlines"

cwlVersion: "v1.0"

doc: |
    Extracts lines from a file

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström


requirements:
  - class: InlineJavascriptRequirement
#  - class: InitialWorkDirRequirement
#    listing:
#      - $( inputs.scriptFolder )

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/bis-snp-utils:0.0.1--pl5.22.0_0"




outputs:
  lines:
    type: string[]

inputs:

  inputFile:
    type: File
    inputBinding:
      loadContents: true

expression: |
  ${
    return { 'lines': inputs.inputFile.contents.split('\n').filter( word => word.length > 0) };
  }


$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl


