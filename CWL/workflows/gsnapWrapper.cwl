cwlVersion: "v1.0"

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
#  - class: StepInputExpressionRequirement

inputs:
  readFiles: File[]
  outputName: string
  sampleSheet: File
  gsnapDB: string
  gsnapDBdir: Directory
  nthreads: int
  readGroupID: string
  readGroupSample: string
  readGroupLibrary: string
  readGroupPlatform: string
  readGroupPlatformUnit: string

outputs:
  bamAlignment:
    type: File
    streamable: true
    outputSource: sortAndRG/OUTPUT_output
  trimLog:
    type: File[]
    outputSource: trim/reportFiles
    
steps:


  trim:
    run: ../tools/bioconda-tool-trim-galore.cwl
    in:
      readFiles: readFiles 
      quality:
        valueFrom: $ ( 20 )
      phred33:
        valueFrom: $( 1==1 )
      paired:
        valueFrom: $( readFiles.length == 2 )
    out:
      - trimmedFiles
      - reportFiles


  alignment:
    run: "../tools/bioconda-tool-gsnap.cwl"
    in:
      output_name:
        valueFrom: "output.bam"
      db: gsnapDB
      dir: gsnapDBdir
      readfile1: 
        valueFrom: $( trim.trimmedFiles[0] )
      readfile2:
        valueFrom: $( trim.trimmedFiles[1] )
      npaths:
        valueFrom: $( 3 )
      nthreads: nthreads
      format:
        valueFrom: "sam"
      mode:
        valueFrom: "cmet-stranded"
      sam-use-0M:
        valueFrom: $( 1==1 )
    out:
      - alignment

  sortAndRG:
    run: ../tools/bioconda-tool-picard-AddOrReplaceReadGroup.cwl
    in:
      INPUT: alignmentSE/alignment
      OUTPUT: outputName
      SORT_ORDER:
        valueFrom: "coordinate"
      RGID: readGroupID
      RGSM: readGroupSample
      RGLB: readGroupLibrary
      RGPL: readGroupPlatform
      RGPU: readGroupPlatformUnit
    out:
      - OUTPUT_output



