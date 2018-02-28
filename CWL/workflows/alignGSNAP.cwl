cwlVersion: v1.0
class: Workflow

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  outputName: string
  perProcessThreads: int
  gsnapDB: string
  gsnapDBdir: Directory
  read1: File[]
  read2:
    type:
      type: array
      items: 
        - "null"
        - File
  readGroupID: string[]
  readGroupSample: string[]
  readGroupLibrary: string[]
  readGroupPlatform: string[]
  readGroupPlatformUnit: string[]


outputs:
  mergedBam:
    type: File
    streamable: true
    outputSource: mergeBam/OUTPUT_output
    
  picardDupMetrics:
    type: File
    outputSource: mergeBam/METRICS_FILE_output
    
  flagstat:
    type: File
    outputSource: flagstat/flagstat
    
  logFiles:
    type: File[]
    outputSource: align/trimLog

    
steps:

  align:
    run: gsnapWrapper.cwl
    scatter: 
      - read1
      - read2
      - readGroupID
      - readGroupSample
      - readGroupLibrary
      - readGroupPlatform
      - readGroupPlatformUnit
    scatterMethod: dotproduct
    in:
      read1: read1
      read2: read2
      readFiles:
        valueFrom: $( [read1, read2] )
      outputName:
        valueFrom: $( read1.replace(/\.(fastq|fq)(\.gz)*$/,"") + ".bam" )
      gsnapDB: gsnapDB
      gsnapDBdir: gsnapDBdir
      nthreads: perProcessThreads
      readGroupID: readGroupID
      readGroupSample: readGroupSample
      readGroupLibrary: readGroupLibrary
      readGroupPlatform: readGroupPlatform
      readGroupPlatformUnit: readGroupPlatformUnit
    out:
      - bamAlignment
      - trimLog

  mergeBam:
    run: ../tools/bioconda-tool-picard-MarkDuplicates.cwl
    in:
      INPUT: align/bamAlignment
      OUTPUT: 
        valueFrom: $( outputName + ".bam" )
      METRICS_FILE:
        valueFrom: $( outputName + ".markDuplicates.txt" )
      CREATE_INDEX:
        valueFrom: $( 1==1 )
    out:
      - OUTPUT_output
      - METRICS_FILE_output
      
  flagstat:
    run: ../tools/bioconda-tool-samtools-flagstat.cwl
    in:
      input: mergeBam/OUTPUT_output
      outputName:
        valueFrom: $( outputName + ".flagstat.txt" )
    out:
      - flagstat

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
