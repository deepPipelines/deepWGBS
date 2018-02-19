cwlVersion: v1.0
class: Workflow

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"



requirements:
  - class: ScatterFeatureRequirement
  

inputs:

  inputfile:
    type: File
    secondaryFiles:
      - "^.bai"

  inputfile_picardDupMetrics:
    type: File

  inputfile_flagstats:
    type: File

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

  outPrefix:
    type: string

  regions:
    type:
      - type: array
        items: 
          - File
          - string

  regionPrefixes:
    type:
      type: array
      items: string

outputs:

steps:

samtools view -F260 -u -b $LOCALINPUTFILE

  removeUnmapped:
    run: dockstore-tool-samtools-view.cwl
    in:
      isbam:
        valueFrom: $( true )
      uncompressed:
        valueFrom: $( true )
      readswithoutbits:
        valueFrom: $( 260 )
      input: inputfile
      output_name:
        valueFrom: $( outPrefix + "onlyPrimary.bam" )
    out:
      - outputs

  realign:
    run: MCSv3_indelRealigner.cwl
    scatter: [regions, regionPrefixes]
    scatterMethod: dotproduct
    in:
      bamFile: removeUnmapped/outputs
      reference: reference
      known_indels: known_indels
      region: regions
      outName: regionPrefixes
    out:
      - realignedBam
      - log_createTarget
      - log_realign

  mergeSam:
    run: Dockerfile_MergeSamFiles.cwl
    in:
      INPUT: realign/realignedBam
      VALIDATION_STRINGENCY:
        valueFrom: $( SILENT )
      MAX_RECORDS_IN_RAM:
        valueFrom: $( 4000000 )
      COMPRESSION_LEVEL:
        valueFrom: $( 0 )
    out:
      - OUTPUT_output

  clipOverlap:
    run: Dockerfile_bamUtils.cwl
    in:
      in: mergeSam/OUTPUT_output
      out: 
        valueFrom: $( outPrefix + ".clipOverlap.bam"
      poolsize:
        valueFrom: $( 2000000 )
    out:
      - out_output

  clipOverlap_correction:
    run:
    in:
      input: clipOverlap/out_output
      output_name: $( outPrefix + ".clipOverlap.corrected.sam"
    out:
      - correctedSam

  clipOverlap_toBam:
    run: dockstore-tool-samtools-view.cwl
    in:
      isbam:
        valueFrom: $( true )
      uncompressed:
        valueFrom: $( true )
      input: clipOverlap_correction/output
      output_name:
        valueFrom: $( outPrefix + ".clipOverlap.clean.bam" )
    out:
      - outputs

  clipOverlap_index:
    run: Dockerfile_samtools-index.cwl
    in:
      input: clipOverlap_toBam/outputs
    out:
      - indexedBam
  
  recalibrate_countCovariates:
    run: Dockerfile_BisulfiteCountCovariates.cwl
    in:
      reference_sequence: reference
      input_file: clipOverlap_index/indexedBam
      knownSites: known_snps
      num_threads:
        valueFrom: $( 6 )
      validation_strictness:
        valueFrom: "LENIENT"
      covariate:
        valueFrom: $( ["ReadGroupCovariate", "QualityScoreCovariate", "CycleCovariate"] )
      recal_file:
        valueFrom: $( outPrefix + ".recal.txt" )
      log_to_file:
        valueFrom: $( outPrefix + ".countCovariates.log" )
    out:
      - recal_file_output
      - log_to_file_output

  recalibrate_call:
    run: MCSv3_recalibrate_call.cwl
    scatter: [ regions, regionPrefixes ]
    scatterMethod: dotproduct
    in:
      reference: reference
      inputBam: clipOverlap_index/indexedBam
      recalFile: recalibrate_countCovariates/recal_file_output
      known_snps: known_snps
      region: regions
      outPrefix: regionPrefixes
    out:

  mergeFiles:
    run:
    in:

    out:

  calculateQC:
    run:
    in:

    out:


