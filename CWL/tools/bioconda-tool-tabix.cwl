#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "bioconda_tabix"
label: "bioconda tabix"

cwlVersion: "v1.0"

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"


requirements:
  - class: InitialWorkDirRequirement
    listing: input
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/tabix:0.2.5"

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000

doc: |
  indexing of block compressed file


baseCommand: ["tabix"]

stdout: $( inputs.output_name )

outputs:
  indexedFile:
    type: File
    secondaryFiles:
      - ".tbi"  
    outputBinding:
      glob: $( inputs.input )
    

inputs:

  input:
    type: File
    inputBinding:
      position: 10
    doc: |
      The file to compress
     
  preset:
    type:
      - 'null'
      - type: enum
        symbols: [gff, bed, sam, vcf, psltbl]
    inputBinding:
      position: 5
      prefix: "-p"
    doc: |
      preset: gff, bed, sam, vcf, psltbl [gff]

  seqCol:
    type: int?
    inputBinding:
      position: 5
      prefix: "-s"
    doc: |
      sequence name column [1]

  startCol:
    type: int?
    inputBinding:
      position: 5
      prefix: "-b"
    doc: |
      start column [4]

  endCol:
    type: int?
    inputBinding:
      position: 5
      prefix: "-e"
    doc: |
      end column; can be identical to '-b' [5]

  skip:
    type: int?
    inputBinding:
      position: 5
      prefix: "-S"
    doc: |
      skip first INT lines [0]

  commentChar:
    type: string?
    inputBinding:
      position: 5
      prefix: "-c"
    doc: |
      symbol for comment/meta lines [#]

  replacementHeader:
    type: File?
    inputBinding:
      position: 5
      prefix: "-r"
    doc: |
      replace the header with the content of FILE [null]

  isBED:
    type: boolean?
    inputBinding:
      position: 5
      prefix: "-B"
    doc: |
      region1 is a BED file (entire file will be read)

  isZeroCoord:
    type: boolean?
    inputBinding:
      position: 5
      prefix: "-0"
    doc: |
      zero-based coordinate

  printHeader:
    type: boolean?
    inputBinding:
      position: 5
      prefix: "-h"
    doc: |
      print the header lines

  listChromNames:
    type: boolean?
    inputBinding:
      position: 5
      prefix: "-l"
    doc: |
      list chromosome names

  overwrite:
    type: boolean?
    inputBinding:
      position: 5
      prefix: "-f"
    doc: |
      force to overwrite the index
 

