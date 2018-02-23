#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "Bis-SNP_genotyper"
label: "Bis-SNP genotyper"

cwlVersion: "v1.0"

doc: |
    ![build_status](https://quay.io/repository/karl616/dockstore-tool-bissnp/status)
    A Docker container containing the Bis-SNP jar file. See the [Bis-SNP](http://people.csail.mit.edu/dnaase/bissnp2011/) webpage for more information.

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström


requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/bis-snp:0.82.2--0"

baseCommand: ["-T", "BisulfiteGenotyper"]

outputs:

  performanceLog_output:
    type: File?
    streamable: false
    outputBinding:
      glob: $( inputs.performanceLog )

  log_to_file_output:
    type: File?
    streamable: false
    outputBinding:
      glob: $( inputs.log_to_file )

  vcf_file_name_1_output:
    type: File
    streamable: false
    outputBinding:
      glob: $( inputs.vcf_file_name_1 )

  file_name_output_verbose_detail_output:
    type: File?
    streamable: false
    outputBinding:
      glob: $( inputs.file_name_output_verbose_detail )

  file_name_output_cpg_reads_detail_output:
    type: File?
    streamable: false
    outputBinding:
      glob: $( inputs.file_name_output_cpg_reads_detail )

  file_name_output_gch_reads_detail_output:
    type: File?
    streamable: false
    outputBinding:
      glob: $( inputs.file_name_output_gch_reads_detail )

  vcf_file_name_2_output:
    type: File
    streamable: false
    outputBinding:
      glob: $( inputs.vcf_file_name_2 )

  coverage_metric_output:
    type: File?
    streamable: false
    outputBinding:
      glob: $( inputs.coverage_metric )

  test_location_output:
    type: File?
    streamable: false
    outputBinding:
      glob: $( inputs.test_location )

inputs:

  arg_file:
    inputBinding:
      position: 5
      prefix: "--arg_file"
    type: File?
    streamable: false
    doc: |
      Reads arguments from the specified file

  input_file:
    inputBinding:
      position: 5
      prefix: "--input_file"
      itemSeparator: " --input_file "
    type: 
      - File
      - type: array
        items: File
    secondaryFiles:
      - "^.bai"
    streamable: false
    doc: |
      SAM or BAM file(s)

  read_buffer_size:
    inputBinding:
      position: 5
      prefix: "--read_buffer_size"
    type: int?
    doc: |
      Number of reads per SAM file to buffer in memory

  phone_home:
    inputBinding:
      position: 5
      prefix: "--phone_home"
    type:
      - "null"
      - type: enum
        symbols: [NO_ET, STANDARD, STDOUT]
    doc: |
      What kind of GATK run report should we generate? STANDARD is the default, can be NO_ET so nothing is posted to the run repository. Please see broadinstitute.org/gsa/wiki/index.php/Phone_home for details. (NO_ET|STANDARD|STDOUT)

  gatk_key:
    inputBinding:
      position: 5
      prefix: "--gatk_key"
    type: File?
    streamable: false
    doc: |
      GATK Key file. Required if running with -et NO_ET. Please see broadinstitute.org/gsa/wiki/index.php/Phone_home for details.

  read_filter:
    inputBinding:
      position: 5
      prefix: "--read_filter"
    type: string?
    doc: |
      Specify filtration criteria to apply to each read individually

  intervals:
    inputBinding:
      position: 5
      prefix: "--intervals"
    type: ["null", string, File]
    doc: |
      One or more genomic intervals over which to operate. Can be explicitly specified on the command line or in a file (including a rod file)

  excludeIntervals:
    inputBinding:
      position: 5
      prefix: "--excludeIntervals"
    type: ["null", string, File]
    doc: |
      One or more genomic intervals to exclude from processing. Can be explicitly specified on the command line or in a file (including a rod file)

  interval_set_rule:
    inputBinding:
      position: 5
      prefix: "--interval_set_rule"
    type:
      - "null"
      - type: enum
        symbols: [UNION, INTERSECTION]
    doc: |
      Indicates the set merging approach the interval parser should use to combine the various -L or -XL inputs (UNION|INTERSECTION)

  interval_merging:
    inputBinding:
      position: 5
      prefix: "--interval_merging"
    type:
      - "null"
      - type: enum
        symbols: [ALL, OVERLAPPING_ONLY]
    doc: |
      Indicates the interval merging rule we should use for abutting intervals (ALL|OVERLAPPING_ONLY)

  reference_sequence:
    inputBinding:
      position: 5
      prefix: "--reference_sequence"
    type: File
    secondaryFiles:
      - ".fai"
      - "^.dict"
    streamable: false
    doc: |
      Reference sequence file

  nonDeterministicRandomSeed:
    inputBinding:
      position: 5
      prefix: "--nonDeterministicRandomSeed"
    type: boolean?
    doc: |
      Makes the GATK behave non deterministically, that is, the random numbers generated will be different in every run

  downsampling_type:
    inputBinding:
      position: 5
      prefix: "--downsampling_type"
    type:
      - "null"
      - type: enum
        symbols: [NONE, ALL_READS, BY_SAMPLE]
    doc: |
      Type of reads downsampling to employ at a given locus. Reads will be selected randomly to be removed from the pile based on the method described here (NONE|ALL_READS|BY_SAMPLE)

  downsample_to_fraction:
    inputBinding:
      position: 5
      prefix: "--downsample_to_fraction"
    type: double?
    doc: |
      Fraction [0.0-1.0] of reads to downsample to

  downsample_to_coverage:
    inputBinding:
      position: 5
      prefix: "--downsample_to_coverage"
    type: int?
    doc: |
      Coverage [integer] to downsample to at any given locus; note that downsampled reads are randomly selected from all possible reads at a locus

  baq:
    inputBinding:
      position: 5
      prefix: "--baq"
    type:
      - "null"
      - type: enum
        symbols: [OFF, CALCULATE_AS_NECESSARY, RECALCULATE]
    doc: |
      Type of BAQ calculation to apply in the engine (OFF|CALCULATE_AS_NECESSARY|RECALCULATE)

  baqGapOpenPenalty:
    inputBinding:
      position: 5
      prefix: "--baqGapOpenPenalty"
    type: int?
    doc: |
      BAQ gap open penalty (Phred Scaled). Default value is 40. 30 is perhaps better for whole genome call sets

  performanceLog:
    inputBinding:
      position: 5
      prefix: "--performanceLog"
    type: string?
    doc: |
      If provided, a GATK runtime performance log will be written to this file

  useOriginalQualities:
    inputBinding:
      position: 5
      prefix: "--useOriginalQualities"
    type: boolean?
    doc: |
      If set, use the original base quality scores from the OQ tag when present instead of the standard scores

  BQSR:
    inputBinding:
      position: 5
      prefix: "--BQSR"
    type: File?
    streamable: false
    doc: |
      Filename for the input covariates table recalibration .csv file which enables on the fly base quality score recalibration

  defaultBaseQualities:
    inputBinding:
      position: 5
      prefix: "--defaultBaseQualities"
    type: int?
    doc: |
      If reads are missing some or all base quality scores, this value will be used for all base quality scores

  validation_strictness:
    inputBinding:
      position: 5
      prefix: "--validation_strictness"
    type:
      - "null"
      - type: enum
        symbols: [STRICT, LENIENT, SILENT]
    doc: |
      How strict should we be with validation (STRICT|LENIENT|SILENT)

  unsafe:
    inputBinding:
      position: 5
      prefix: "--unsafe"
    type:
      - "null"
      - type: enum
        symbols: [ALLOW_UNINDEXED_BAM, ALLOW_UNSET_BAM_SORT_ORDER, NO_READ_ORDER_VERIFICATION, ALLOW_SEQ_DICT_INCOMPATIBILITY, ALL]
    doc: |
      If set, enables unsafe operations: nothing will be checked at runtime. For expert users only who know what they are doing. We do not support usage of this argument. (ALLOW_UNINDEXED_BAM|ALLOW_UNSET_BAM_SORT_ORDER|NO_READ_ORDER_VERIFICATION|ALLOW_SEQ_DICT_INCOMPATIBILITY|ALL)

  num_threads:
    inputBinding:
      position: 5
      prefix: "--num_threads"
    type: int?
    doc: |
      How many threads should be allocated to running this analysis.

  num_bam_file_handles:
    inputBinding:
      position: 5
      prefix: "--num_bam_file_handles"
    type: int?
    doc: |
      The total number of BAM file handles to keep open simultaneously

  read_group_black_list:
    inputBinding:
      position: 5
      prefix: "--read_group_black_list"
    type: File?
    streamable: false
    doc: |
      Filters out read groups matching <TAG>:<STRING> or a .txt file containing the filter strings one per line.

  pedigree:
    inputBinding:
      position: 5
      prefix: "--pedigree"
    type: File?
    streamable: false
    doc: |
      Pedigree files for samples

  pedigreeString:
    inputBinding:
      position: 5
      prefix: "--pedigreeString"
    type: string?
    doc: |
      Pedigree string for samples

  pedigreeValidationType:
    inputBinding:
      position: 5
      prefix: "--pedigreeValidationType"
    type:
      - "null"
      - type: enum
        symbols: [STRICT, SILENT]
    doc: |
      How strict should we be in validating the pedigree information? (STRICT|SILENT)

  logging_level:
    inputBinding:
      position: 5
      prefix: "--logging_level"
    type:
      - "null"
      - type: enum
        symbols: [INFO, ERROR, FATAL]
    doc: |
      Set the minimum level of logging, i.e. setting INFO get's you INFO up to FATAL, setting ERROR gets you ERROR and FATAL level logging.

  log_to_file:
    inputBinding:
      position: 5
      prefix: "--log_to_file"
    type: string?
    doc: |
      Set the logging location

  vcf_file_name_1:
    inputBinding:
      position: 5
      prefix: "--vcf_file_name_1"
    type: string
    default: cpgs.vcf
    doc: |
      output Vcf file, when used for [DEFAULT_FOR_TCGA] output mode, it is used to store all CpG sites. While the original vcf file is to store all CpG sites

  non_directional_protocol:
    inputBinding:
      position: 5
      prefix: "--non_directional_protocol"
    type: boolean?
    doc: |
      false: Illumina protocol which is often used, only bisulfite conversion strand is kept (Lister protocol, sequence 2 forward strands only); true: Cokus protocol, sequence all 4 bisulfite converted strands

  bisulfite_conversion_rate:
    inputBinding:
      position: 5
      prefix: "--bisulfite_conversion_rate"
    type: double?
    doc: |
      bisulfite conversion rate

  cytosine_contexts_acquired:
    type:
      - "null"
      - type: array
        items: string
        inputBinding:
          prefix: "--cytosine_contexts_acquired"
    inputBinding:
      position: 5
    doc: |
      Specify the cytosine contexts to check (e.g. -C CG,1,0.7 CG is the methylation pattern to check, 1 is the C's position in CG pattern, 0.7 is the initial cytosine pattern methylation level. You could specify '-C' multiple times for different cytosine pattern)

  dbsnp:
    inputBinding:
      position: 5
      prefix: "--dbsnp"
    type: File?
    secondaryFiles:
      ".idx"
    streamable: false
    doc: |
      dbSNP file

  file_name_output_verbose_detail:
    inputBinding:
      position: 5
      prefix: "--file_name_output_verbose_detail"
    type: string?
    doc: |
      output file that contain verbose information, for test only

  locus_not_continuous:
    inputBinding:
      position: 5
      prefix: "--locus_not_continuous"
    type: boolean?
    doc: |
      loci to look at is not continuous, if the distance is too large, it will make some trouble in multithread VCF writer, just enable this option in performance test only

  max_mismatches:
    inputBinding:
      position: 5
      prefix: "--max_mismatches"
    type: int?
    doc: |
      Maximum number of mismatches within a 40 bp window (20bp on either side) around the target position for a read to be used for calling

  min_mapping_quality_score:
    inputBinding:
      position: 5
      prefix: "--min_mapping_quality_score"
    type: int?
    doc: |
      Minimum mapping quality required to consider a base for calling

  minmum_cytosine_converted:
    inputBinding:
      position: 5
      prefix: "--minmum_cytosine_converted"
    type: int?
    doc: |
      disregard first few cytosines in the reads which may come from uncomplete bisulfite conversion in the first few cytosines of the reads (5'end) 

  novelDbsnpHet:
    inputBinding:
      position: 5
      prefix: "--novelDbsnpHet"
    type: double?
    doc: |
      heterozygous SNP rate when the loci is discovered as SNP in dbSNP and but not validated, the default value is human genome

  output_reads_after_downsampling:
    inputBinding:
      position: 5
      prefix: "--output_reads_after_downsampling"
    type: boolean?
    doc: |
      output Bam file that after downsapling, for performance test only (CWL: not forwarded to output)

  output_reads_coverage_after_downsampling:
    inputBinding:
      position: 5
      prefix: "--output_reads_coverage_after_downsampling"
    type: boolean?
    doc: |
      define output Bam file's mean coverage that after downsapling, for performance test only (CWL: not forwarded to output)

  output_modes:
    inputBinding:
      position: 5
      prefix: "--output_modes"
    type:
      - "null"
      - type: enum
        symbols: [DEFAULT_FOR_TCGA, EMIT_ALL_CONFIDENT_SITES, NOMESEQ_MODE, EMIT_ALL_CPG, EMIT_ALL_CYTOSINES, EMIT_ALL_SITES, EMIT_HET_SNPS_ONLY, EMIT_VARIANT_AND_CYTOSINES, EMIT_VARIANTS_ONLY]
    doc: |
      Output S,EMIT_ALL_SITES,EMIT_ALL_CPG, _CYTOSINES,EMIT_HET_SNPS_ONLY, DEFAULT_FOR_TCGA, EMIT_VARIANT_AND_CYTOSINES, NOMESEQ_MODE] (DEFAULT_FOR_TCGA|EMIT_ALL_CONFIDENT_SITES|NOMESEQ_MODE|EMIT_ALL_CPG|EMIT_ALL_CYTOSINES|EMIT_ALL_SITES|EMIT_HET_SNPS_ONLY|EMIT_VARIANT_AND_CYTOSINES|EMIT_VARIANTS_ONLY)

  output_verbose_detail:
    inputBinding:
      position: 5
      prefix: "--output_verbose_detail"
    type: boolean?
    doc: |
      output_verbose_detail, for performance test only

  over_conversion_rate:
    inputBinding:
      position: 5
      prefix: "--over_conversion_rate"
    type: double?
    doc: |
      cytosine over conversion rate. it is often 0

  reference_genome_error:
    inputBinding:
      position: 5
      prefix: "--reference_genome_error"
    type: double?
    doc: |
      Reference genome error, the default value is human genome, in hg16 it is 99.99% accurate, in hg17/hg18/hg19, it is less than 1e-4 (USCS genome browser described); We define it here default for human genome assembly(hg18,h19) to be 1e-6 as GATK did 

  sequencing_mode:
    inputBinding:
      position: 5
      prefix: "--sequencing_mode"
    type:
      - "null"
      - type: enum
        symbols: [BM, GM, NM]
    doc: |
      Bisulfite mode: BM, GNOMe-seq mode: GM (BM|GM|NM)

  test_location:
    inputBinding:
      position: 5
      prefix: "--test_location"
    type: string?
    streamable: false
    doc: |
      for debug only, output the detail information in the location

  ti_vs_tv:
    inputBinding:
      position: 5
      prefix: "--ti_vs_tv"
    type: double?
    doc: |
      Transition rate vs. Transversion rate, in human genome, the default is 2

  maximum_read_cov:
    inputBinding:
      position: 5
      prefix: "--maximum_read_cov"
    type: int?
    doc: |
      maximum read coverage allowed. Default is: 250

  trim_3_end_bp:
    inputBinding:
      position: 5
      prefix: "--trim_3_end_bp"
    type: int?
    doc: |
      how many bases at 3'end of the reads are discarded

  trim_5_end_bp:
    inputBinding:
      position: 5
      prefix: "--trim_5_end_bp"
    type: int?
    doc: |
      how many bases at 5'end of the reads are discarded

  trim_only_2nd_end_reads:
    inputBinding:
      position: 5
      prefix: "--trim_only_2nd_end_reads"
    type: boolean?
    doc: |
      Only trimmed at 2nd end reads, should be enabled for tagmentation-based whole genome bisulfite sequencing

  use_badly_mated_reads:
    inputBinding:
      position: 5
      prefix: "--use_badly_mated_reads"
    type: boolean?
    doc: |
      use badly mated reads for calling

  invert_dups_usage:
    inputBinding:
      position: 5
      prefix: "--invert_dups_usage"
    type:
      - "null"
      - type: enum
        symbols: [USE_ONLY_1ST_END, USE_BOTH_END, NOT_TO_USE]
    doc: |
      how to use the end when met inverted dups reads[USE_ONLY_1ST_END, USE_BOTH_END, NOT_TO_USE]. (Default: USE_ONLY_1ST_END) (USE_ONLY_1ST_END|USE_BOTH_END|NOT_TO_USE)

  use_baq_for_calculation:
    inputBinding:
      position: 5
      prefix: "--use_baq_for_calculation"
    type: boolean?
    doc: |
      use BAQ for genotype calculation

  validateDbsnphet:
    inputBinding:
      position: 5
      prefix: "--validateDbsnphet"
    type: double?
    doc: |
      heterozygous SNP rate when the loci is discovered as SNP in dbSNP and is validated, the default value is human genome

  maximum_cache_for_output_vcf:
    inputBinding:
      position: 5
      prefix: "--maximum_cache_for_output_vcf"
    type: int?
    doc: |
      maximum cached position for multithreads output of VCF. Default is: 10,000,000

  include_cytosine_no_coverage:
    inputBinding:
      position: 5
      prefix: "--include_cytosine_no_coverage"
    type: boolean?
    doc: |
      including all of cytosine pattern in reference genome, even it does not have any reads covered. Default: false

  include_snp_in_cpg_reads_file:
    inputBinding:
      position: 5
      prefix: "--include_snp_in_cpg_reads_file"
    type: boolean?
    doc: |
      only output heterozygous SNP in cpg reads file. Default: false

  only_output_dbsnp_in_cpg_reads_file:
    inputBinding:
      position: 5
      prefix: "--only_output_dbsnp_in_cpg_reads_file"
    type: boolean?
    doc: |
      only output heterozygous SNP at known dbSNP position in cpg reads file (need to enable -includeSnp at the sam time). Default: false

  not_encrypt:
    inputBinding:
      position: 5
      prefix: "--not_encrypt"
    type: boolean?
    doc: |
      In cpg reads file, output original reads ID rather than the output of encrypt id. Default: false

  genotype_likelihoods_model:
    inputBinding:
      position: 5
      prefix: "--genotype_likelihoods_model"
    type:
      - "null"
      - type: enum
        symbols: [SNP, INDEL, BOTH]
    doc: |
      Genotype likelihoods calculation model to employ, SNP is the default option, while INDEL is also available for calling indels and BOTH is available for calling both together (SNP|INDEL|BOTH)

  p_nonref_model:
    inputBinding:
      position: 5
      prefix: "--p_nonref_model"
    type:
      - "null"
      - type: enum
        symbols: [EXACT, GRID_SEARCH]
    doc: |
      Non-reference probability calculation model to employ, EXACT is the default option, while GRID_SEARCH is also available. (EXACT)

  heterozygosity:
    inputBinding:
      position: 5
      prefix: "--heterozygosity"
    type: double?
    doc: |
      Heterozygosity value used to compute prior likelihoods for any locus

  pcr_error_rate:
    inputBinding:
      position: 5
      prefix: "--pcr_error_rate"
    type: double?
    doc: |
      The PCR error rate to be used for computing fragment-based likelihoods

  genotyping_mode:
    inputBinding:
      position: 5
      prefix: "--genotyping_mode"
    type:
      - "null"
      - type: enum
        symbols: [DISCOVERY, GENOTYPE_GIVEN_ALLELES]
    doc: |
      Should we output confident genotypes (i.e. including ref calls) or just the variants? (DISCOVERY|GENOTYPE_GIVEN_ALLELES)

  output_mode:
    inputBinding:
      position: 5
      prefix: "--output_mode"
    type:
      - "null"
      - type: enum
        symbols: [EMIT_VARIANTS_ONLY, EMIT_ALL_CONFIDENT_SITES, EMIT_ALL_SITES]
    doc: |
      Should we output confident genotypes (i.e. including ref calls) or just the variants? (EMIT_VARIANTS_ONLY|EMIT_ALL_CONFIDENT_SITES|EMIT_ALL_SITES)

  standard_min_confidence_threshold_for_calling:
    inputBinding:
      position: 5
      prefix: "--standard_min_confidence_threshold_for_calling"
    type: int?
    doc: |
      The minimum phred-scaled confidence threshold at which variants not at 'trigger' track sites should be called

  standard_min_confidence_threshold_for_emitting:
    inputBinding:
      position: 5
      prefix: "--standard_min_confidence_threshold_for_emitting"
    type: int?
    doc: |
      The minimum phred-scaled confidence threshold at which variants not at 'trigger' track sites should be emitted (and filtered if less than the calling threshold)

  noSLOD:
    inputBinding:
      position: 5
      prefix: "--noSLOD"
    type: boolean?
    doc: |
      If provided, we will not calculate the SLOD

  alleles:
    inputBinding:
      position: 5
      prefix: "--alleles"
    type: string?
    doc: |
      The set of alleles at which to genotype when in GENOTYPE_MODE = GENOTYPE_GIVEN_ALLELES

  min_base_quality_score:
    inputBinding:
      position: 5
      prefix: "--min_base_quality_score"
    type: int?
    doc: |
      Minimum base quality required to consider a base for calling

  max_deletion_fraction:
    inputBinding:
      position: 5
      prefix: "--max_deletion_fraction"
    type: double?
    doc: |
      Maximum fraction of reads with deletions spanning this locus for it to be callable [to disable, set to: < 0 or > 1; default:0.05]

  max_alternate_alleles:
    inputBinding:
      position: 5
      prefix: "--max_alternate_alleles"
    type: int?
    doc: |
      Maximum number of alternate alleles to genotype

  min_indel_count_for_genotyping:
    inputBinding:
      position: 5
      prefix: "--min_indel_count_for_genotyping"
    type: int?
    doc: |
      Minimum number of consensus indels required to trigger genotyping run

  indel_heterozygosity:
    inputBinding:
      position: 5
      prefix: "--indel_heterozygosity"
    type: string?
    doc: |
      Heterozygosity for indel calling

  file_name_output_cpg_reads_detail:
    inputBinding:
      position: 5
      prefix: "--file_name_output_cpg_reads_detail"
    type: string?
    doc: |
      output Haplotype CpG reads bed file that contain each CpG's position, methylation and reads name info 

  file_name_output_gch_reads_detail:
    inputBinding:
      position: 5
      prefix: "--file_name_output_gch_reads_detail"
    type: string?
    doc: |
      output Haplotype GCH reads bed file that contain each GCH position, methylation and reads name info 

  vcf_file_name_2:
    inputBinding:
      position: 5
      prefix: "--vcf_file_name_2"
    type: string
    default: "snps.vcf"
    doc: |
      output Vcf file 2, only used for [DEFAULT_FOR_TCGA] output mode, it is used to store all SNP sites. While the original vcf file is to store all CpG sites

  coverage_metric:
    inputBinding:
      position: 5
      prefix: "--coverage_metric"
    type: string?
    doc: |
      output coverage metric files, 1st column is coverage, 2nd column is '1' when give -cgi option and inside this option's file region, otherwise they are all '0' ??should we seperate it to another walker?

  cgi_file:
    inputBinding:
      position: 5
      prefix: "--cgi_file"
    type: File?
    streamable: false
    doc: |
      Give the CGI bed file for the coverage estimation

  filter_mismatching_base_and_quals:
    inputBinding:
      position: 5
      prefix: "--filter_mismatching_base_and_quals"
    type: boolean?
    doc: |
      if a read has mismatching number of bases and base qualities, filter out the read instead of blowing up.


$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
