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

  sampleName: string
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
  
  known_indels:
    type: File
    secondaryFiles:
      - ".idx"
  known_snps:
    type: File
    secondaryFiles:
      - ".idx"
  reference:
    type: File
    secondaryFiles:
      - ".fai"

  reference_lengths:
    type: File 

outputs:

  multiQCreport:
    type: File
    outputBinding:
      outputSource: multiQC/multiQCreport
  
  logFolder:
    type: Directory
    outputBinding:
      outputSource: multiQC/logFolder
      
  cpgbedFile:
    type: File
    secondaryFiles:
      - ".tbi"
    outputSource: callMeth/cpgbedFile

  coverageBigwig:
    type: File
    outputSource: callMeth/coverageBigwig

  methBigwig:
    type: File
    outputSource: callMeth/methBigwig

  cpgVCFfile:
    type: File
    secondaryFiles:
      - ".tbi"
    outputSource: callMeth/cpgVCFfile

  snpVCFfile:
    type: File
    secondaryFiles:
      - ".tbi"
    outputSource: callMeth/snpVCFfile


steps:  
  
  align:
    run: workflows/alignGSNAP.cwl
    in:
      outputName: sampleName
      perProcessThreads: 
        valueFrom: $( 8 )
      gsnapDB: gsnapDB
      gsnapDBdir: gsnapDBdir
      read1: read1
      read2: read2
      readGroupID: readGroupID
      readGroupSample: readGroupSample
      readGroupLibrary: readGroupLibrary
      readGroupPlatform: readGroupPlatform
      readGroupPlatformUnit: readGroupPlatformUnit
    out:
      - mergedBam
      - picardDupMetrics
      - flagstat
      - logFiles

  extractRegions:
    run: workflows/getChrNameFromBam.cwl
    in:
      input: align/mergedBam
    out:
      - chrNames
 
  callMeth:
    run: workflows/MCSv3.cwl
    in:
      inputfile: align/mergedBam
      inputfile_picardDupMetrics: align/picardDupMetrics
      inputfile_flagstats: align/flagstats
      known_indels: known_indels
      known_snps: known_snps
      reference: reference
      reference_lengths: reference_lengths
      outPrefix: sampleName
      regions: extractRegions/chrNames
      regionPrefixes: extractRegions/chrNames
    out:
      - logFiles
      - cpgbedFile
      - coverageBigwig
      - methBigwig
      - cpgVCFfile
      - snpVCFfile
        
  multiQC:
  run: tools/localfile-tool-multiQCwrapper.cwl
  in:
    input:
      valueFrom: $( align.logFiles.concat(callMeth.logFiles) )
    outputPrefix: sampleName
  out:
    - logFolder
    - multiQCreport

  
$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
