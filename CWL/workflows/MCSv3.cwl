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

  cpg_islands:
    type: File

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
    type: File[]
    outputSource: mergeLogs/arrayOut

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
      bamFile: removeUnmapped/bamFile
      reference: reference
      known_indels: known_indels
      region: regions
      outName: regionPrefixes
    out:
      - realignedBam
      - logFiles

  mergeSam:
    run: ../tools/bioconda-tool-picard-MergeSamFiles.cwl
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
        valueFrom: $( outPrefix + ".clipOverlap.bam" )
      poolsize:
        valueFrom: $( 2000000 )
    out:
      - out_output

  clipOverlap_correction:
    run: ../tools/localfile-tool-clipOverlapCorrection.cwl
    in:
      input: clipOverlap/out_output
      output_name: 
        valueFrom: $( outPrefix + ".clipOverlap.corrected.sam" )
    out:
      - correctedSam

  clipOverlap_toBam:
    run: ../tools/bioconda-tool-samtools-view.cwl
    in:
      outBam:
        valueFrom: $( true )
      useNoCompression:
        valueFrom: $( true )
      input: clipOverlap_correction/correctedSam
      outputFileName:
        valueFrom: $( outPrefix + ".clipOverlap.clean.bam" )
    out:
      - bamFile

  clipOverlap_index:
    run: ../tools/bioconda-samtools-index.cwl
    in:
      input: clipOverlap_toBam/bamFile
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
      - logFiles

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
    out:
      - bigwigFile

  bamQC:
    run: ../tools/localfile-tool-genMetaBam.cwl
    in:
      LOCALINPUTFILE: mergeBam/OUTPUT_output
      output_name: $( outPrefix + ".recal.bam.qc" )
    out:
      - metadata

  bedQC:
    run: ../tools/localfile-tool-genMetaBed.cwl
    in:
      CPG_ISLANDS: cpg_islands
      bedFile: indexBED/indexedFile
      output_name: $( outPrefix + ".filtered.CG.bed.qc.txt")
    out:
      - metadata
      - methFile
      - covFile

  picardQC:
    run: ../tools/localfile-tool-genMetaPic.cwl
    in:
      INPUTFILE_PICARDDUPMETRICS: inputfile_picardDupMetrics
      INPUTFILE_FLAGSTATS: inputfile_flagstats
      output_name: $( outPrefix + ".alignment.qc.txt"
    out:
      - metadata

  vcfQC:
    run: ../tools/localfile-tool-genMetaVcf.cwl
    in:
      REFERENCE: reference
      SNP: indexVCFcpg/indexedFile
      CPG: indexVCFcpg/indexedFile
      output_name: $( outPrefix + ".filtered.vcf.qc.txt" )
    out:
      - metadata

  mergeLogs:
    run: ../tools/localfile-expressionTool-concatenateFileArray.cwl
    in:
      array1:
        valueFrom: |
          ${
            return bamQC.metadata.concat(
              bedQC.metadata).concat(
              bedQC.methFile).concat(
              bedQC.covFile).concat(
              picardQC.metadata).concat(
              vcfQC.metadata);
          }
      array2:
        valueFrom: |
          ${
            var arr=recalibrate_countCovariates.log_to_file_output;
            for(var i=0; i<recalibrate_call.logFiles.length; i++){
              arr=arr.concat(recalibrate_call.logFiles[i];
            }
            for(var i=0; i<realign.logFiles.length; i++){
              arr=arr.concat(realign.logFiles[i];
            }
            return arr;
          }
    out:
      - arrayOut

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
