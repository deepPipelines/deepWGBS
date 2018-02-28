cwlVersion: v1.0
class: Workflow

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström

inputs:

  bamFile:
    type: File
    secondaryFiles:
      - "^.bai"

  reference:
    type: File
    secondaryFiles:
      - ".fai"

  known_indels:
    type: File
    secondaryFiles:
      - ".idx"

  region:
    type:
      - string
      - File

  outName: string


outputs:

  realignedBam:
    type: File
    outputSource: realign/out_output
  logFiles:
    type: File[]
    outputSource: mergeLogs/arrayOut

steps:

  createTargets:
    run: ../tools/bioconda-tool-BisSNP-BisulfiteRealignerTargetCreator.cwl
    in:
      input_file: bamFile
      intervals: region
      reference_sequence: reference
      validation_strictness:
        valueFrom: LENIENT
      num_threads:
        valueFrom: $( 7 )
      log_to_file: 
        valueFrom: $( inputs.outName + ".TargetCreator.log")
      known: known_indels
      out: outName
    out:
      - out_output
      - log_to_file_output


  realign:
    run: ../tools/bioconda-tool-BisSNP-BisulfiteIndelRealigner.cwl
    in:
      input_file: bamFile
      intervals: region
      reference_sequence: reference
      validation_strictness:
        valueFrom: LENIENT
      log_to_file:
        valueFrom: $( inputs.outName + ".realignment.log"
      targetIntervals: createTargets/out_output
      knownAlleles: known_indels
      IgnoreOriginalCigar:
        valueFrom: $( 1==1 )
      maxReadsInMemory:
        valueFrom: $( 1500000 )
      out: outName
    out:
      - out_output
      - log_to_file_output

  mergeLogs:
    run: ../tools/localfile-expressionTool-concatenateFileArray.cwl
    in:
      array1:
        valueFrom: $( [ createTargets/log_to_file_output ] )
      array2:
        valueFrom: $( [ realign/log_to_file_output ] )
    out:
      - arrayOut

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
