#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

id: FastQC
label: FastQC

doc: |
  FastQC reads a set of sequence files and produces from each one a quality
  control report consisting of a number of different modules, each one of 
  which will help to identify a different potential type of problem in your
  data.
  
  If no files to process are specified on the command line then the program
  will start as an interactive graphical application.  If files are provided
  on the command line then the program will run with no user interaction
  required.  In this mode it is suitable for inclusion into a standardised
  analysis pipeline.

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/fastqc:0.11.7--pl5.22.0_0"

baseCommand: ["fastqc"]

outputs:
  zippedFile:
    type: File[]
    outputBinding:
      glob: '*.zip'
  report:
    type: Directory
    outputBinding:
      glob: .

inputs:

  fastqFiles:
    type: File[]
    inputBinding:
      position: 10

  casava:
    type: boolean?
    inputBinding:
      position: 5
      prefix: --casava
    doc: |
      Files come from raw casava output. Files in the same sample
      group (differing only by the group number) will be analysed
      as a set rather than individually. Sequences with the filter
      flag set in the header will be excluded from the analysis.
      Files must have the same names given to them by casava
      (including being gzipped and ending with .gz) otherwise they
      won't be grouped together correctly.

  nano:
    type: boolean?
    inputBinding:
      position: 5
      prefix: --nano
    doc: |
      Files come from naopore sequences and are in fast5 format. In
      this mode you can pass in directories to process and the program
      will take in all fast5 files within those directories and produce
      a single output file from the sequences found in all files.                    

  nofilter:
    type: boolean?
    inputBinding:
      position: 5
      prefix: --nofilter
    doc: |
      If running with --casava then don't remove read flagged by
      casava as poor quality when performing the QC analysis.

  extract:
    type: boolean?
    inputBinding:
      position: 5
      prefix: --extract
    doc: |
      If set then the zipped output file will be uncompressed in
      the same directory after it has been created.  By default
      this option will be set if fastqc is run in non-interactive
      mode.

  java:
    type: string?
    inputBinding:
      position: 5
      prefix: --java
    doc: |
      Provides the full path to the java binary you want to use to
      launch fastqc. If not supplied then java is assumed to be in
      your path.

  noextract:
    type: boolean?
    inputBinding:
      position: 5
      prefix: --noextract
    doc: |
      Do not uncompress the output file after creating it.  You
      should set this option if you do not wish to uncompress
      the output when running in non-interactive mode.

  nogroup:
    type: boolean?
    inputBinding:
      position: 5
      prefix: --nogroup
    doc: |
      Disable grouping of bases for reads >50bp. All reports will
      show data for every base in the read.  WARNING, Using this
      option will cause fastqc to crash and burn if you use it on
      really long reads, and your plots may end up a ridiculous size.
      You have been warned!

  min_length:
    type: int?
    inputBinding:
      position: 5
      prefix: --min_length
    doc: |
      Sets an artificial lower limit on the length of the sequence
      to be shown in the report.  As long as you set this to a value
      greater or equal to your longest read length then this will be
      the sequence length used to create your read groups.  This can
      be useful for making directly comaparable statistics from 
      datasets with somewhat variable read lengths.

  format:
    type:
      - "null"
      - type: enum
        symbols: [bam, sam, bam_mapped, sam_mapped, fastq]
    inputBinding:
      position: 5
      prefix: --format
    doc: |
      Bypasses the normal sequence file format detection and
      forces the program to use the specified format.  Valid
      formats are bam,sam,bam_mapped,sam_mapped and fastq

  threads:
    type: int?
    inputBinding:
      position: 5
      prefix: --threads
    doc: |
      Specifies the number of files which can be processed
      simultaneously.  Each thread will be allocated 250MB of
      memory so you shouldn't run more threads than your
      available memory will cope with, and not more than
      6 threads on a 32 bit machine

  contaminants:
    type: File?
    inputBinding:
      position: 5
      prefix: --contaminants
    doc: |
      Specifies a non-default file which contains the list of
      contaminants to screen overrepresented sequences against.
      The file must contain sets of named contaminants in the
      form name[tab]sequence.  Lines prefixed with a hash will
      be ignored.

  adapters:
    type: File?
    inputBinding:
      position: 5
      prefix: --adapters
    doc: |
      Specifies a non-default file which contains the list of
      adapter sequences which will be explicity searched against
      the library. The file must contain sets of named adapters
      in the form name[tab]sequence.  Lines prefixed with a hash
      will be ignored.

  limits:
    type: File?
    inputBinding:
      position: 5
      prefix: --limits
    doc: |
      Specifies a non-default file which contains a set of criteria
      which will be used to determine the warn/error limits for the
      various modules.  This file can also be used to selectively 
      remove some modules from the output all together.  The format
      needs to mirror the default limits.txt file found in the
      Configuration folder.

  kmers:
    type: int?
    inputBinding:
      position: 5
      prefix: --kmers
    doc: |
      Specifies the length of Kmer to look for in the Kmer content
      module. Specified Kmer length must be between 2 and 10. Default
      length is 7 if not specified.

  quiet:
    type: boolean?
    inputBinding:
      position: 5
      prefix: --quiet
    doc: |
      Supress all progress messages on stdout and only report errors.

  dir:
    type: string?
    inputBinding:
      position: 5
      prefix: --dir
    doc: |
      Selects a directory to be used for temporary files written when
      generating report images. Defaults to system temp directory if
      not specified.


arguments:
- valueFrom: "."
  prefix: "--outdir"
  position: 5
- valueFrom: "--extract"
  position: 5

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
