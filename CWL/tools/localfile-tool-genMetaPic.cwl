#!usr/bin/env cwl-runner

class: CommandLineTool

id: "genMetaPic"
label: "genMetaPic"

cwlVersion: "v1.0"

doc: |
    Generates meta data from duplication data files.

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
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/YAP_MCSv3:0.0.1"

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000

baseCommand: ["genMetaPic"]

stdout: $( inputs.output_name + '.txt' )

outputs:
  metadata:
    type: stdout

inputs:

  PARAMETERFILE:
    type: File
    inputBinding:
      position: 1
      prefix: -p

  INPUTFILE_PICARDDUPMETRICS:
   type: File
   inputBinding:
     position: 2
     prefix: -d

  INPUTFILE_FLAGSTATS:
   type: File
   inputBinding:
     position: 3
     prefix: -f

  output_name:
    type: string
    inputBinding:
     position: 4
     prefix: -o
    doc: |
      Name of output file

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
 - https://schema.org/docs/schema_org_rdfa.html
 - http://edamontology.org/EDAM_1.18.owl
