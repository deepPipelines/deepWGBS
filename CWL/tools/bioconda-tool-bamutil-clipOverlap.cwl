#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "bam_clipOverlap"
label: "bam clipOverlap"

cwlVersion: "v1.0"

doc: |
    ![build_status](https://quay.io/repository/karl616/dockstore-tool-picard/status)
    A Docker container containing bamUtil. See the [bamUtil](https://genome.sph.umich.edu/wiki/BamUtil) webpage for more information.

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"


requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/bamutil:1.0.14--2"

baseCommand: ["bam", "clipOverlapping"]

outputs:

  out_output:
    type: File
    outputBinding:
      glob: $( inputs.out )

inputs:

  in:
    inputBinding:
      position: 5
      prefix: "--in"
    type: File
    doc: |
      the SAM/BAM file to clip overlaping read pairs for

  out:
    inputBinding:
      position: 5
      prefix: "--out"
    type: string
    doc: |
      the SAM/BAM file to be written

  storeOrig:
    inputBinding:
      position: 5
      prefix: "--storeOrig"
    type: boolean?
    doc: |
      Store the original cigar in the specified tag.

  readName:
    inputBinding:
      position: 5
      prefix: "--readName"
    type: boolean?
    doc: |
      Original file is sorted by Read Name instead of coordinate.

  stats:
    inputBinding:
      position: 5
      prefix: "--stats"
    type: boolean?
    doc: |
      Print some statistics on the overlaps.

  overlapsOnly:
    inputBinding:
      position: 5
      prefix: "--overlapsOnly"
    type: boolean?
    doc: |
      Only output overlapping read pairs

  excludeFlags:
    inputBinding:
      position: 5
      prefix: "--excludeFlags"
    type: int?
    doc: |
      Skip records with any of the specified flags set, default 0x70C

  noeof:
    inputBinding:
      position: 5
      prefix: "--noeof"
    type: boolean?
    doc: |
      Do not expect an EOF block on a bam file.

  params:
    inputBinding:
      position: 5
      prefix: "--params"
    type: boolean?
    doc: |
      Print the parameter settings to stderr

  poolsize:
    inputBinding:
      position: 5
      prefix: "--poolSize"
    type: int?
    doc: |
      Maximum number of records the program is allowed to allocate for clipping on Coordinate sorted files. (Default: 1000000)

  poolSkipClip:
    inputBinding:
      position: 5
      prefix: "--poolSkipClip"
    type: boolean?
    doc: |
      Skip clipping reads to free of usable records when the poolSize is hit. The default action is to just clip the first read in a pair to free up the record.

