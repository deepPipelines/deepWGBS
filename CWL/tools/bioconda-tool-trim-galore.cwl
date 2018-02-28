#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "trim_galore"
label: "trim_galore"

cwlVersion: "v1.0"

doc: |
    Trims FASTQ files for quality and adapter

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström


requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing: $( inputs.readFiles )

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/trim-galore:0.4.5--pl5.22.0_1"


baseCommand: ["trim_galore"]

outputs:

  trimmedFiles:
    type:
      type: array
      items: File
    outputBinding:
      glob: |
        ${
          function getFileName(x){
            var name = x.basename.replace(/\.(fastq|fq)(\.gz)*$/,"");
            var suffix = (inputs.paired ? "_val_*.fq.gz" : "_trimmed.fq.gz");
            return name + suffix;
          }
          return inputs.readFiles.map( getFileName );
        }


  reportFiles:
    type:
      type: array
      items: File
    outputBinding:
      glob: ${
          function getReportName(x){
            return x.basename + "_trimming_report.txt";
          }
          return inputs.readFiles.map( getReportName );
        }

inputs:

  readFiles:
    type:
      type: array
      items: File
    inputBinding:
      position: 15
    doc: |
      Read 1


  quality:
    type: int?
    inputBinding:
      position: 10
      prefix: --quality
    doc: |
      Trim low-quality ends from reads in addition to adapter removal. For
      RRBS samples, quality trimming will be performed first, and adapter
      trimming is carried in a second round. Other files are quality and adapter
      trimmed in a single pass. The algorithm is the same as the one used by BWA
      (Subtract INT from all qualities; compute partial sums from all indices
      to the end of the sequence; cut sequence at the index at which the sum is
      minimal). Default Phred score: 20.

  phred33:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --phred33
    doc: |
      Instructs Cutadapt to use ASCII+33 quality scores as Phred scores
      (Sanger/Illumina 1.9+ encoding) for quality trimming. Default: ON.

  phred64:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --phred64
    doc: |
      Instructs Cutadapt to use ASCII+64 quality scores as Phred scores
      (Illumina 1.5 encoding) for quality trimming.

  fastqc:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --fastqc
    doc: |
      Run FastQC in the default mode on the FastQ file once trimming is complete.

  fastqc_args:
    type: string?
    inputBinding:
      position: 10
      prefix: --fastqc_args
    doc: |
      Passes extra arguments to FastQC. If more than one argument is to be passed
      to FastQC they must be in the form "arg1 arg2 etc.". An example would be:
      --fastqc_args "--nogroup --outdir /home/". Passing extra arguments will
      automatically invoke FastQC, so --fastqc does not have to be specified
      separately.

  adapter:
    type: string?
    inputBinding:
      position: 10
      prefix: --adapter
    doc: |
      Adapter sequence to be trimmed. If not specified explicitly, Trim Galore will
      try to auto-detect whether the Illumina universal, Nextera transposase or Illumina
      small RNA adapter sequence was used. Also see '--illumina', '--nextera' and
      '--small_rna'. If no adapter can be detected within the first 1 million sequences
      of the first file specified Trim Galore defaults to '--illumina'.

  adapter2:
    type: string?
    inputBinding:
      position: 10
      prefix: --adapter2
    doc: |
      Optional adapter sequence to be trimmed off read 2 of paired-end files. This
      option requires '--paired' to be specified as well. If the libraries to be trimmed
      are smallRNA then a2 will be set to the Illumina small RNA 5' adapter automatically
      (GATCGTCGGACT).

  illumina:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --illumina
    doc: |
      Adapter sequence to be trimmed is the first 13bp of the Illumina universal adapter
      'AGATCGGAAGAGC' instead of the default auto-detection of adapter sequence.
  
  nextera:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --nextera
    doc: |
      Adapter sequence to be trimmed is the first 12bp of the Nextera adapter
      'CTGTCTCTTATA' instead of the default auto-detection of adapter sequence.

  small_rna:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --small_rna
    doc: |
      Adapter sequence to be trimmed is the first 12bp of the Illumina Small RNA 3' Adapter
      'TGGAATTCTCGG' instead of the default auto-detection of adapter sequence. Selecting
      to trim smallRNA adapters will also lower the --length value to 18bp. If the smallRNA
      libraries are paired-end then a2 will be set to the Illumina small RNA 5' adapter
      automatically (GATCGTCGGACT) unless -a 2 had been defined explicitly.

  max_length:
    type: int?
    inputBinding:
      position: 10
      prefix: --max_length
    doc: |
      Discard reads that are longer than <INT> bp after trimming. This is only advised for
      smallRNA sequencing to remove non-small RNA sequences.

  stringency:
    type: int?
    inputBinding:
      position: 10
      prefix: --stringency
    doc: |
      Overlap with adapter sequence required to trim a sequence. Defaults to a
      very stringent setting of 1, i.e. even a single bp of overlapping sequence
      will be trimmed off from the 3' end of any read.

  error_rate:
    type: float?
    inputBinding:
      position: 10
      prefix: -e
    doc: |
      Maximum allowed error rate (no. of errors divided by the length of the matching
      region) (default: 0.1)

  gzip:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --gzip
    doc: |
      Compress the output file with GZIP. If the input files are GZIP-compressed
      the output files will automatically be GZIP compressed as well. As of v0.2.8 the
      compression will take place on the fly.

  dont_gzip:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --dont_gzip
    doc: |
      Output files won't be compressed with GZIP. This option overrides --gzip.
  
  length:
    type: int?
    inputBinding:
      position: 10
      prefix: --length
    doc: |
      Discard reads that became shorter than length INT because of either
      quality or adapter trimming. A value of '0' effectively disables
      this behaviour. Default: 20 bp.

      For paired-end files, both reads of a read-pair need to be longer than
      <INT> bp to be printed out to validated paired-end files (see option --paired).
      If only one read became too short there is the possibility of keeping such
      unpaired single-end reads (see --retain_unpaired). Default pair-cutoff: 20 bp.

  max_n:
    type: int?
    inputBinding:
      position: 10
      prefix: --max_n
    doc: |
      The total number of Ns (as integer) a read may contain before it will be removed altogether.
      In a paired-end setting, either read exceeding this limit will result in the entire
      pair being removed from the trimmed output files.

  trim-n:
    type: int?
    inputBinding:
      position: 10
      prefix: --trim-n
    doc: |
      Removes Ns from either side of the read. This option does currently not work in RRBS mode.

  output_dir:
    type: string?
    inputBinding:
      position: 10
      prefix: --output_dir
    doc: |
      If specified all output will be written to this directory instead of the current
      directory.

  no_report_file:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --no_report_file
    doc: |
      If specified no report file will be generated.

  suppress_warn:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --suppress_warn
    doc: |
      If specified any output to STDOUT or STDERR will be suppressed.

  clip_R1:
    type: int?
    inputBinding:
      position: 10
      prefix: --clip_R1
    doc: |
      Instructs Trim Galore to remove <int> bp from the 5' end of read 1 (or single-end
      reads). This may be useful if the qualities were very poor, or if there is some
      sort of unwanted bias at the 5' end. Default: OFF.

  clip_R2:
    type: int?
    inputBinding:
      position: 10
      prefix: --clip_R2
    doc: |
      Instructs Trim Galore to remove <int> bp from the 5' end of read 2 (paired-end reads
      only). This may be useful if the qualities were very poor, or if there is some sort
      of unwanted bias at the 5' end. For paired-end BS-Seq, it is recommended to remove
      the first few bp because the end-repair reaction may introduce a bias towards low
      methylation. Please refer to the M-bias plot section in the Bismark User Guide for
      some examples. Default: OFF.

  three_prime_clip_R1:
    type: int?
    inputBinding:
      position: 10
      prefix: --three_prime_clip_R1
    doc: |
      Instructs Trim Galore to remove <int> bp from the 3' end of read 1 (or single-end
      reads) AFTER adapter/quality trimming has been performed. This may remove some unwanted
      bias from the 3' end that is not directly related to adapter sequence or basecall quality.
      Default: OFF.

  three_prime_clip_R2:
    type: int?
    inputBinding:
      position: 10
      prefix: --three_prime_clip_R2
    doc: |
      Instructs Trim Galore to remove <int> bp from the 3' end of read 2 AFTER
      adapter/quality trimming has been performed. This may remove some unwanted bias from
      the 3' end that is not directly related to adapter sequence or basecall quality.
      Default: OFF.

  path_to_cutadapt:
    type: File?
    inputBinding:
      position: 10
      prefix: --path_to_cutadapt
    doc: |
      You may use this option to specify a path to the Cutadapt executable,
      e.g. /my/home/cutadapt-1.7.1/bin/cutadapt. Else it is assumed that Cutadapt is in
      the PATH.

  rrbs:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --rrbs
    doc: |
      Specifies that the input file was an MspI digested RRBS sample (recognition
      site: CCGG). Single-end or Read 1 sequences (paired-end) which were adapter-trimmed
      will have a further 2 bp removed from their 3' end. Sequences which were merely
      trimmed because of poor quality will not be shortened further. Read 2 of paired-end
      libraries will in addition have the first 2 bp removed from the 5' end (by setting 
      '--clip_r2 2'). This is to avoid using artificial methylation calls from the filled-in
      cytosine positions close to the 3' MspI site in sequenced fragments. 
      This option is not recommended for users of the NuGEN ovation RRBS System 1-16
      kit (see below).

  non_directional:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --non_directional
    doc: |
      Selecting this option for non-directional RRBS libraries will screen
      quality-trimmed sequences for 'CAA' or 'CGA' at the start of the read
      and, if found, removes the first two basepairs. Like with the option
      '--rrbs' this avoids using cytosine positions that were filled-in
      during the end-repair step. '--non_directional' requires '--rrbs' to
      be specified as well. Note that this option does not set '--clip_r2 2' in
      paired-end mode.

  keep:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --keep
    doc: |
      Keep the quality trimmed intermediate file. Default: off, which means
      the temporary file is being deleted after adapter trimming. Only has
      an effect for RRBS samples since other FastQ files are not trimmed
      for poor qualities separately.

  paired:
    type: boolean
    default: false
    inputBinding:
      position: 10
      prefix: --paired
    doc: |
      This option performs length trimming of quality/adapter/RRBS trimmed reads for
      paired-end files. To pass the validation test, both sequences of a sequence pair
      are required to have a certain minimum length which is governed by the option
      --length (see above). If only one read passes this length threshold the
      other read can be rescued (see option --retain_unpaired). Using this option lets
      you discard too short read pairs without disturbing the sequence-by-sequence order
      of FastQ files which is required by many aligners.
      
      Trim Galore! expects paired-end files to be supplied in a pairwise fashion, e.g.
      file1_1.fq file1_2.fq SRR2_1.fq.gz SRR2_2.fq.gz ... .

  trim1:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --trim1
    doc: |
      Trims 1 bp off every read from its 3' end. This may be needed for FastQ files that
      are to be aligned as paired-end data with Bowtie. This is because Bowtie (1) regards
      alignments like this:
      
        R1 --------------------------->     or this:    ----------------------->  R1
        R2 <---------------------------                       <-----------------  R2
      
      as invalid (whenever a start/end coordinate is contained within the other read).
      NOTE: If you are planning to use Bowtie2, BWA etc. you don't need to specify this option.

  retain_unpaired:
    type: boolean?
    inputBinding:
      position: 10
      prefix: --retain_unpaired
    doc: |
      If only one of the two paired-end reads became too short, the longer
      read will be written to either '.unpaired_1.fq' or '.unpaired_2.fq'
      output files. The length cutoff for unpaired single-end reads is
      governed by the parameters -r1/--length_1 and -r2/--length_2. Default: OFF.

  length_1:
    type: int?
    inputBinding:
      position: 10
      prefix: --length_1
    doc: |
      Unpaired single-end read length cutoff needed for read 1 to be written to
      '.unpaired_1.fq' output file. These reads may be mapped in single-end mode.
      Default: 35 bp.

  length_2:
    type: int?
    inputBinding:
      position: 10
      prefix: --length_2
    doc: |
      Unpaired single-end read length cutoff needed for read 2 to be written to
      '.unpaired_2.fq' output file. These reads may be mapped in single-end mode.
      Default: 35 bp.


$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
