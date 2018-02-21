#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "YAP_MCSv3_multiQCwrapper"
label: "YAP MCSv3 multiQCwrapper"

cwlVersion: "v1.0"

doc: |
    combines all log files

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"


requirements:
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/multiqc:1.5a--py36_0"

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000

baseCommand: ["multiQCwrapper"]



outputs:

  logFolder:
    type: Directory
    outputBinding:
      glob: $( inputs.outputPrefix + "_logfiles" )

  multiQCreport:
    type: File
    secondaryFiles:
      - "^_data"
    outputBinding:
      glob: $( inputs.outputPrefix + ".html" )

inputs:

  input:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -i
    inputBinding:
      position: 5
    doc: |
      inputlog file (can be given multiple times)

  outputPrefix:
    type: string
    inputBinding:
      position: 5
      prefix: -o
    doc: |
      output prefix
