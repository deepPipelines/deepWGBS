cwlVersion: v1.0
class: Workflow

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"



requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  

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

  scriptFolder:
    type: Directory

outputs:

  cpgbedFile:
    type: File
    secondaryFiles:
      - ".tbi"
    outputSource: indexBED/indexedFile

  coverageBigwig:
    type: File
    outputSource: createCoverageBigwig/bigwigFile

  methBigwig:
    type: File
    outputSource: createMethBigWig/bigwigFile

  cpgVCFfile:
    type: File
    secondaryFiles:
      - ".tbi"
    outputSource: indexVCFcpg/indexedFile

  snpVCFfile:
    type: File
    secondaryFiles:
      - ".tbi"
    outputSource: indexVCFsnp/indexedFile

  recalibratedBam:
    type: File
    secondaryFiles:
      - ".bai"
    outputSource: indexBam/indexedBam

  logFiles:
    type: Directory
    outputSource: multiQCreport/logFolder

  multiQC:
    type: File
    secondaryFiles:
      - "^_data"
    outputSource: multiQCreport/multiQCreport

steps:

  removeUnmapped:
    run: ../tools/bioconda-tool-samtools-view.cwl
    in:
      outbam:
        valueFrom: $( true )
      useNoCompression:
        valueFrom: $( true )
      selectFLAGnone:
        valueFrom: $( 260 )
      input: inputfile
      outputFileName:
        valueFrom: $( outPrefix + "onlyPrimary.bam" )
    out:
      - bamFile

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
    run: ../tools/bioconda-tool-picard-_MergeSamFiles.cwl
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
    run: ../tools/bioconda-tool-bamutil-clipOverlap.cwl
    in:
      in: mergeSam/OUTPUT_output
      out: 
        valueFrom: $( outPrefix + ".clipOverlap.bam"
      poolsize:
        valueFrom: $( 2000000 )
    out:
      - out_output

  clipOverlap_correction:
    run: ../tools/localfile-tool-clipOverlapCorrection.cwl
    in:
      input: clipOverlap/out_output
      output_name: $( outPrefix + ".clipOverlap.corrected.sam"
    out:
      - correctedSam

  clipOverlap_toBam:
    run: ../tools/bioconda-tool-samtools-view.cwl
    in:
      outBam:
        valueFrom: $( true )
      useNoCompression:
        valueFrom: $( true )
      input: clipOverlap_correction/output
      outputFileName:
        valueFrom: $( outPrefix + ".clipOverlap.clean.bam" )
    out:
      - outputs

  clipOverlap_index:
    run: ../tools/bioconda-samtools-index.cwl
    in:
      input: clipOverlap_toBam/outputs
    out:
      - indexedBam
  
  recalibrate_countCovariates:
    run: ../tools/bioconda-tool-BisSNP-BisulfiteCountCovariates.cwl
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
      - snpvcf
      - cpgvcf
      - calibratedBam
      - cpgbed
      - summary_VCFpostprocessSNP
      - summary_VCFpostprocessCpG
      - log_recalibrate
      - log_methylation_call
      - log_VCFpostprocessSNP
      - log_VCFpostprocessCpG

  mergeBam:
    run: ../tools/bioconda-tool-picard-MergeSamFiles.cwl
    in:
      VALIDATION_STRINGENCY:
        valueFrom: "LENIENT"
      INPUT: recalibrate_call/calibratedBam
      OUTPUT:
        valueFrom: $( outPrefix + ".recal.bam" )
    out:
      - OUTPUT_output

  indexBam:
    run: ../tools/bioconda-tool-samtools-index.cwl
    in:
      input: mergeBam/OUTPUT_output
    out:
      - indexedBam

  mergeVCFcpg:
    run: ../tools/localfile-tool-mergeVCF.cwl
    in:
      input: recalibrate_call/cpgvcf
      output_name:
        valueFrom: $( outPrefix + ".filtered.cpg.vcf"
      scriptFolder: scriptFolder
    out:
      - mergedVCF
    
  indexVCFcpg:
    run: compressIndexTabix.cwl
    in:
      input: mergeVCFcpg/mergedVCF
      filetype:
        valueFrom: "vcf"
    out:
      - indexedFile

  mergeVCFsnp:
    run: ../tools/localfile-tool-mergeVCF.cwl
    in:
      input: recalibrate_call/snpvcf
      output_name:
        valueFrom: $( outPrefix + ".filtered.snp.vcf"
      scriptFolder: scriptFolder
    out:
      - mergedVCF

  indexVCFsnp:
    run: compressIndexTabix.cwl
    in:
      input: mergeVCFsnp/mergedVCF
      filetype:
        valueFrom: "vcf"
    out:
      - indexedFile

  mergeBED:
    run: ../tools/localfile-tool-mergeBED.cwl
    in:
      input: recalibrate_call/cpgbed
      sample_name: outPrefix
      output_name:
        valueFrom: $( outPrefix + ".filtered.CG.bed" )
      scriptFolder: scriptFolder
    out:
      - mergedBED

  indexBED:
    run: compressIndexTabix.cwl
    in:
      input: mergeBED/mergedBED
      filetype:
        valueFrom: "bed"
    out:
      - indexedFile

  createCoverageBigwig:
    run: ../tools/localfile-tool-bigWigBEDcol.cwl
    in:
      input: mergeBED/mergedBED
      chromSizeFile: reference_lengths
      columnToUse:
        valueFrom: 5
      output_name:
        valueFrom: $( outPrefix + ".filtered.CG.ct_coverage.bw" )
      scriptFolder: scriptFolder
    out:
      - bigwigFile

  createMethBigWig:
    run: ../tools/localfile-tool-bigWigBEDcol.cwl
    in:
      input: mergeBED/mergedBED
      chromSizeFile: reference_lengths
      columnToUse:
        valueFrom: 4
      output_name:
        valueFrom: $( outPrefix + ".filtered.CG.bw" )
      scriptFolder: scriptFolder
    out:
      - bigwigFile

  bamQC:
    run:
    in:

    out:

  bedQC:
    run:
    in:

    out:

  vcfQC:
    run:
    in:

    out:

  

  multiQCreport:
    run: ../tools/localfile-tool-multiQCwrapper.cwl
    in:
      input:
        valueFrom: $(
            realign.log_createTarget.concat(
              realign.log_realign).concat(
              recalibrate_countCovariates.log_to_file_output).concat(
              recalibrate_call.log_recalibrate).concat(
              recalibrate_call.log_methylation_call).concat(
              recalibrate_call.log_VCFpostprocessSNP).concat(
              recalibrate_call.log_VCFpostprocessCpG)
          )
      outputPrefix: outPrefix
    out:
      - logFolder
      - multiQCreport




