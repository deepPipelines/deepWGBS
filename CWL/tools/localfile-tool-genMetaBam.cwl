#!usr/bin/env cwl-runner

class: CommandLineTool

id: "genMetaBam"
label: "genMetaBam"

cwlVersion: "v1.0"

doc: |
    Generates meta data from Bam file.

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström

s:contributor:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0003-1381-257X
    s:email: mailto:dania.humaidan@gmail.com
    s:name: Dania Humaidan

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - inputs.scriptFoldere

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/bis-snp-utils:0.0.1--pl5.22.0_0"


baseCommand: ["scripts/genMetaBam"]

stdout: $( inputs.output_name + '.txt')

outputs:
  metadata:
    type: stdout

inputs:

  LOCALINPUTFILE:
    type: File
    inputBinding:
      position: 1
      prefix: -i

  output_name:
    type: string
    inputBinding:
      position: 2
      prefix: -o
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

