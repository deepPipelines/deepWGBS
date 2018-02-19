cwlVersion: v1.0
class: Workflow

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"



inputs:

  reference:
    type: File
    secondaryFiles:
      - ".fai"

  inputBam:
    type: File
    secondaryFiles:
      - "^.bai"

  recalFile: File

  region:
    type:
      - string
      - File

  known_snps:
    type: File
    secondaryFiles:
      - ".idx"

  outPrefix: string

outputs:


  snpvcf:
    type: File
    outputSource: VCFpostprocessSNP/new_vcf_output
  cpgvcf:
    type: File
    outputSource: VCFpostprocessCpG/new_vcf_output
  cpgbed:
    type: File
    outputSource: convertToBed/CpGbed
  summary_VCFpostprocessSNP:
    type: File?
    outputSource: VCFpostprocessSNP/out_output
  summary_VCFpostprocessCpG:
    type: File?
    outputSource: VCFpostprocessCpG/out_output
  log_recalibrate:
    type: File?
    outputSource: recalibrate/log_to_file_output
  log_methylation_call:
    type: File?
    outputSource: methylation_call/log_to_file_output
  log_VCFpostprocessSNP:
    type: File?
    outputSource: VCFpostprocessSNP/log_to_file_output
  log_VCFpostprocessCpG:
    type: File?
    outputSource: VCFpostprocessCpG/log_to_file_output

steps:

  recalibrate:
    run: Dockerfile_BisulfiteTableRecalibration.cwl
    in:
      reference_sequence: reference
      input_file: inputBam
      out:
        valueFrom: $( outPrefix + ".recal.bam" )
      recal_file: recalFile
      log_to_file:
        valueFrom: $( outPrefix + ".recalibration.log" )
      validation_strictness:
        valueFrom: "LENIENT"
      intervals: region
    out:
      - out_output
      - log_to_file_output

  methylation_call:
    run: Dockerfile_BisulfiteGenotyper.cwl
    in:
      reference_sequence: reference
      input_file: recalibrate/out_output
      vcf_file_name_1:
        valueFrom: $( outPrefix + ".cpg.raw.vcf" )
      vcf_file_name_2:
        valueFrom: $( outPrefix + ".snp.raw.vcf" )
      log_to_file:
        valueFrom: $( outPrefix + ".call.log" )
      dbsnp: known_snps
      interval: region
      validation_strictness:
        valueFrom: "LENIENT"
      num_threads:
        valueFrom: $( 7 )
      output_modes:
        valueFrom: "EMIT_VARIANT_AND_CYTOSINES"
      standard_min_confidence_threshold_for_emitting:
        valueFrom: $( 0 )
      cytosine_contexts_acquired:
        valueFrom: $( ["CG,1", "CA,1", "CC,1", "CT,1", "CAG,1", "CHH,1", "CHG,1", "GC,2", "GCH,2", "GCG,2", "HCG,2", "HCH,2", "HCA,2", "HCC,2", "HCT,2"] )
    out:
      - log_to_file_output
      - vcf_file_name_1_output
      - vcf_file_name_2_output

  sortSNP:
    run: Dockerfile_sortByRefAndCor.cwl
    in:
      input: methylation_call/vcf_file_name_1_output
      ref_dict:
        valueFrom: $( reference.secondaryFiles[0] )
      namePosition:
        valueFrom: $( 1 )
      coordinatePosition:
        valueFrom: $( 2 )
      outputName:
        valueFrom: $( outPrefix + ".snp.raw.sorted.vcf")
    out:
      - sortedVcf

  sortCpG:
    run: Dockerfile_sortByRefAndCor.cwl
    in:
      input: methylation_call/vcf_file_name_2_output
      ref_dict:
        valueFrom: $( reference.secondaryFiles[0] )
      namePosition:
        valueFrom: $( 1 )
      coordinatePosition:
        valueFrom: $( 2 )
      outputName:
        valueFrom: $( outPrefix + ".cpg.raw.sorted.vcf" )
    out:
      - sortedVcf

  VCFpostprocessSNP:
    run: Dockerfile_VCFpostprocess.cwl
    in:
      reference_sequence: reference
      new_vcf:
        valueFrom: $( outPrefix + ".snp.filtered.vcf" )
      old_vcf: sortSNP/sortedVcf
      snp_vcf: sortSNP/sortedVcf
      out:
        valueFrom: $( outPrefix + ".snp.raw.filter.summary.txt"
      log_to_file:
        valueFrom: $( outPrefix + ".snp.raw.filter.log"
    out:
      - new_vcf_output
      - out_output
      - log_to_file_output

  VCFpostprocessCpG:
    run: Dockerfile_VCFpostprocess.cwl
    in:
      reference_sequence: reference
      new_vcf:
        valueFrom: $( outPrefix + ".cpg.filtered.vcf" )
      old_vcf: sortCpG/sortedVcf
      snp_vcf: sortSNP/sortedVcf
      out:
        valueFrom: $( outPrefix + ".cpg.raw.filter.summary.txt"
      log_to_file:
        valueFrom: $( outPrefix + ".cpg.raw.filter.log"
    out:
      - new_vcf_output
      - out_output
      - log_to_file_output

  convertToBed:
    run: Dockerfile_vcf2bed.NOME.cwl
    in:
      input: VCFpostprocessCpG/new_vcf_output
      context:
        valueFrom: "CG"
      outputName:
        valueFrom: $( outPrefix + ".cpg.filtered.CG.bed" )
    out:
      - CpGbed

