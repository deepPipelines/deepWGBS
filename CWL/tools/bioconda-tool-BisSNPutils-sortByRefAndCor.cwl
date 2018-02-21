#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "Bis-SNP_sortByRefAndCor"
label: "Bis-SNP sortByRefAndCor"

cwlVersion: "v1.0"

doc: |
    ![build_status](https://quay.io/repository/karl616/dockstore-tool-bissnp/status)
    A Docker container containing the Bis-SNP utility scripts. See the [Bis-SNP](http://people.csail.mit.edu/dnaase/bissnp2011/) webpage for more information.

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"


requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/bis-snp-utils:0.0.1--pl5.22.0_0"

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000

doc: |
  Sorts lines of the input file INFILE according
  to the reference contig order specified by the
  reference dictionary REF_DICT (.fai file).
  The sort is stable. If -k option is not specified,
  it is assumed that the contig name is the first
  field in each line.

baseCommand: ["sortByRefAndCor.pl"]

stdout: $( outputName )

outputs:
  
  sortedVcf:
    type: stdout

inputs:
  outputName:
    type: string
    doc: |
      File name to use for the output file

  input:
    inputBinding:
      position: 10
      prefix: "-k"
    type: File
    streamable: true
    doc: |
      input file to sort. If '-' is specified, then reads from STDIN. (CWL: STDIN is not accepted)

  ref_dict:
    inputBinding:
      position: 20
    type: File
    doc: |
      .fai file, or ANY file that has contigs, in the desired soting order, as its first column.

  namePosition:
    inputBinding:
      position: 5
      prefix: "--k"
    type: int
    doc: |
      contig name is in the field POS (1-based) of input lines.

  coordinatePosition:
    inputBinding:
      position: 5
      prefix: "--c"
    type: int
    doc: |
      contig cordinate is in the field COR (1-based) of input lines.

  tempDirectory:
    inputBinding:
      position: 5
      prefix: "--tmp"
    type: string?
    doc: |
      temp directory 

