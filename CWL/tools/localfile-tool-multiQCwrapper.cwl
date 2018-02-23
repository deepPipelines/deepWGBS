#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "YAP_MCSv3_multiQCwrapper"
label: "YAP MCSv3 multiQCwrapper"

cwlVersion: "v1.0"

doc: |
    combines all log files

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
    dockerPull: "quay.io/biocontainers/multiqc:1.5a--py36_0"

baseCommand: ["bash", "scripts/multiQCwrapper"]



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
