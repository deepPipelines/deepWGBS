#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "Bis-SNP_IndelRealigner"
label: "Bis-SNP IndelRealigner"

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

baseCommand: ["-T", "BisulfiteIndelRealigner"]


outputs:

  out_output:
    type: File
    secondaryFiles:
      - "^.bai"
    outputBinding:
      glob: $( inputs.out )

  performanceLog_output:
    type: File?
    outputBinding:
      glob: $( inputs.performanceLog )

  log_to_file_output:
    type: File?
    outputBinding:
      glob: $( inputs.log_to_file )


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
      Indicates the interval merging rule we should use for abutting intervals (ALL| OVERLAPPING_ONLY)

  reference_sequence:
    inputBinding:
      position: 5
      prefix: "--reference_sequence"
    type: File
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
      How strict should we be with validation (STRICT| LENIENT|SILENT)

  unsafe:
    inputBinding:
      position: 5
      prefix: "--unsafe"
    type:
      - "null"
      - type: enum
        symbols: [ALLOW_UNINDEXED_BAM, ALLOW_UNSET_BAM_SORT_ORDER, NO_READ_ORDER_VERIFICATION, ALLOW_SEQ_DICT_INCOMPATIBILITY, ALL]
    doc: |
      If set, enables unsafe operations: nothing will be checked at runtime. For expert users only who know what they are doing. We do not support usage of this argument. (ALLOW_UNINDEXED_BAM| ALLOW_UNSET_BAM_SORT_ORDER| NO_READ_ORDER_VERIFICATION| ALLOW_SEQ_DICT_INCOMPATIBILITY|ALL)

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
        symbols: [INFO, FATAL, ERROR]
    doc: |
      Set the minimum level of logging, i.e. setting INFO get's you INFO up to FATAL, setting ERROR gets you ERROR and FATAL level logging.

  log_to_file:
    inputBinding:
      position: 5
      prefix: "--log_to_file"
    type: string?
    doc: |
      Set the logging location

  targetIntervals:
    inputBinding:
      position: 5
      prefix: "--targetIntervals"
    type: File
    streamable: false
    doc: |
      intervals file output from RealignerTargetCreator

  consensusDeterminationModel:
    inputBinding:
      position: 5
      prefix: "--consensusDeterminationModel"
    type:
      - "null"
      - type: enum
        symbols: [KNOWNS_ONLY, USE_READS, USE_SW]
    doc: |
      Determines how to compute the possible alternate consenses (KNOWNS_ONLY|USE_READS|USE_SW)

  knownAlleles:
    inputBinding:
      position: 5
      prefix: "--knownAlleles"
    type:
      - File
      - type: array
        items: File
    secondaryFiles:
      - ".idx"
    doc: |
      Input VCF file(s) with known indels

  IgnoreOriginalCigar:
    inputBinding:
      position: 5
      prefix: "--IgnoreOriginalCigar"
    type: boolean?
    doc: |
      For most of bisulfite mapping program(except Novo-aligner/Bismark with Bowtie2 as i know), they did not output CIGAR string correctly, so enable this option to igore the original CIGAR

  LODThresholdForCleaning:
    inputBinding:
      position: 5
      prefix: "--LODThresholdForCleaning"
    type: int?
    doc: |
      LOD threshold above which the cleaner will clean

  maxConsensuses:
    inputBinding:
      position: 5
      prefix: "--maxConsensuses"
    type: int?
    doc: |
      max alternate consensuses to try (necessary to improve performance in deep coverage)

  maxIsizeForMovement:
    inputBinding:
      position: 5
      prefix: "--maxIsizeForMovement"
    type: int?
    doc: |
      maximum insert size of read pairs that we attempt to realign

  maxPositionalMoveAllowed:
    inputBinding:
      position: 5
      prefix: "--maxPositionalMoveAllowed"
    type: int?
    doc: |
      maximum positional move in basepairs that a read can be adjusted during realignment

  maxReadsForRealignment:
    inputBinding:
      position: 5
      prefix: "--maxReadsForRealignment"
    type: int?
    doc: |
      max reads allowed at an interval for realignment

  maxReadsForConsensuses:
    inputBinding:
      position: 5
      prefix: "--maxReadsForConsensuses"
    type: int?
    doc: |
      max reads used for finding the alternate consensuses (necessary to improve performance in deep coverage)

  maxReadsInMemory:
    inputBinding:
      position: 5
      prefix: "--maxReadsInMemory"
    type: int?
    doc: |
      max reads allowed to be kept in memory at a time by the SAMFileWriter

  entropyThreshold:
    inputBinding:
      position: 5
      prefix: "--entropyThreshold"
    type: double?
    doc: |
      percentage of mismatches at a locus to be considered having high entropy

  nWayOut:
    inputBinding:
      position: 5
      prefix: "--nWayOut"
    type: boolean?
    doc: |
      Generate one output file for each input (-I) bam file (CWL: not handled)

  noOriginalAlignmentTags:
    inputBinding:
      position: 5
      prefix: "--noOriginalAlignmentTags"
    type: boolean?
    doc: |
      Don't output the original cigar or alignment start tags for each realigned read in the output bam

  out:
    inputBinding:
      position: 5
      prefix: "--out"
    type: string
    default: "out.bam"
    doc: |
      Output bam

  bam_compression:
    inputBinding:
      position: 5
      prefix: "--bam_compression"
    type: int?
    doc: |
      Compression level to use for writing BAM files

  disable_bam_indexing:
    inputBinding:
      position: 5
      prefix: "--disable_bam_indexing"
    type: boolean?
    doc: |
      Turn off on-the-fly creation of indices for output BAM files.

  generate_md5:
    inputBinding:
      position: 5
      prefix: "--generate_md5"
    type: boolean?
    doc: |
      Enable on-the-fly creation of md5s for output BAM files.

  simplifyBAM:
    inputBinding:
      position: 5
      prefix: "--simplifyBAM"
    type: boolean?
    doc: |
      If provided, output BAM files will be simplified to include just key reads for downstream variation discovery analyses (removing duplicates, PF-, non-primary reads), as well stripping all extended tags from the kept reads except the read group identifier

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
