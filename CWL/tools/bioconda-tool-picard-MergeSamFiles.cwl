#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "Picard_MergeSamFiles"
label: "Picard MergeSamFiles"

cwlVersion: "v1.0"

doc: |
    ![build_status](https://quay.io/repository/karl616/dockstore-tool-picard/status)
    A Docker container containing the Picard jar file. See the [Picard](http://broadinstitute.github.io/picard/) webpage for more information.

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"


requirements:
  - class: InlineJavascriptRequirement

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/picard:2.17.2--py36_0"

baseCommand: ["picard", "MergeSamFiles"]

outputs:

  OUTPUT_output:
    type: File
    streamable: true
    outputBinding:
      glob: $( inputs.OUTPUT )

inputs:

  TMP_DIR:
    inputBinding:
      position: 5
      prefix: "TMP_DIR="
      separate: false
    type: string?
    doc: |
       One or more directories with space available to be used by this program for temporary storage of working files Default value: null. This option may be specified 0 or more times. 

  VERBOSITY:
    inputBinding:
      position: 5
      prefix: "VERBOSITY="
      separate: false
    type:
      - 'null'
      - type: enum
        symbols: [ERROR, WARNING, INFO, DEBUG]
    doc: |
       Control verbosity of logging. Default value: INFO. This option can be set to 'null' to clear the default value. Possible values: {ERROR, WARNING, INFO, DEBUG} 

  QUIET:
    inputBinding:
      position: 5
      prefix: "QUIET=true"
      separate: false
    type: boolean?
    doc: |
       Whether to suppress job-summary info on System.err. Default value: false. This option can be set to 'null' to clear the default value. Possible values: {true, false} 

  VALIDATION_STRINGENCY:
    inputBinding:
      position: 5
      prefix: "VALIDATION_STRINGENCY="
      separate: false
    type:
      - 'null'
      - type: enum
        symbols: [STRICT, LENIENT, SILENT]
    doc: |
       Validation stringency for all SAM files read by this program. Setting stringency to SILENT can improve performance when processing a BAM file in which variable-length data (read, qualities, tags) do not otherwise need to be decoded. Default value: STRICT. This option can be set to 'null' to clear the default value. Possible values: {STRICT, LENIENT, SILENT} 

  COMPRESSION_LEVEL:
    inputBinding:
      position: 5
      prefix: "COMPRESSION_LEVEL="
      separate: false
    type: int?
    doc: |
       Compression level for all compressed files created (e.g. BAM and VCF). Default value: 5. This option can be set to 'null' to clear the default value. 

  MAX_RECORDS_IN_RAM:
    inputBinding:
      position: 5
      prefix: "MAX_RECORDS_IN_RAM="
      separate: false
    type: int?
    doc: |
       When writing files that need to be sorted, this will specify the number of records stored in RAM before spilling to disk. Increasing this number reduces the number of file handles needed to sort the file, and increases the amount of RAM needed. Default value: 500000. This option can be set to 'null' to clear the default value. 

  CREATE_INDEX:
    inputBinding:
      position: 5
      prefix: "CREATE_INDEX=true"
      separate: false
    type: boolean?
    doc: |
       Whether to create a BAM index when writing a coordinate-sorted BAM file. Default value: false. This option can be set to 'null' to clear the default value. Possible values: {true, false} 

  CREATE_MD5_FILE:
    inputBinding:
      position: 5
      prefix: "CREATE_MD5_FILE=true"
      separate: false
    type: boolean?
    doc: |
       Whether to create an MD5 digest for any BAM or FASTQ files created. Default value: false. This option can be set to 'null' to clear the default value. Possible values: {true, false} 

  REFERENCE_SEQUENCE:
    inputBinding:
      position: 5
      prefix: "REFERENCE_SEQUENCE="
      separate: false
    type: File
    doc: |
       Reference sequence file. Default value: null. 

  GA4GH_CLIENT_SECRETS:
    inputBinding:
      position: 5
      prefix: "GA4GH_CLIENT_SECRETS="
      separate: false
    type: File?
    doc: |
       Google Genomics API client_secrets.json file path. Default value: client_secrets.json. This option can be set to 'null' to clear the default value. 

  USE_JDK_DEFLATER:
    inputBinding:
      position: 5
      prefix: "USE_JDK_DEFLATER=true"
      separate: false
    type: boolean?
    doc: |
       Use the JDK Deflater instead of the Intel Deflater for writing compressed output Default value: false. This option can be set to 'null' to clear the default value. Possible values: {true, false} 

  USE_JDK_INFLATER:
    inputBinding:
      position: 5
      prefix: "USE_JDK_INFLATER=true"
      separate: false
    type: boolean?
    doc: |
       Use the JDK Inflater instead of the Intel Inflater for reading compressed input Default value: false. This option can be set to 'null' to clear the default value. Possible values: {true, false} 

  OPTIONS_FILE:
    inputBinding:
      position: 5
      prefix: "OPTIONS_FILE="
      separate: false
    type: File?
    doc: |
       File of OPTION_NAME=value pairs. No positional parameters allowed. Unlike command-line options, unrecognized options are ignored. A single-valued option set in an options file may be overridden by a subsequent command-line option. A line starting with '#' is considered a comment. Required. 

  INPUT:
    inputBinding:
      position: 5
    type: 
      type: array
      items: File
      inputBinding:
        prefix: "INPUT="
        separate: false
    doc: |
       SAM or BAM input file Default value: null. This option must be specified at least 1 times. 

  OUTPUT:
    inputBinding:
      position: 5
      prefix: "OUTPUT="
      separate: false
    type: string
    doc: |
       SAM or BAM file to write merged result to Required. 

  SORT_ORDER:
    inputBinding:
      position: 5
      prefix: "SORT_ORDER="
      separate: false
    type:
      - 'null'
      - type: enum
        symbols: [unsorted, queryname, coordinate, duplicate, unknown]
    doc: |
       Sort order of output file Default value: coordinate. This option can be set to 'null' to clear the default value. Possible values: {unsorted, queryname, coordinate, duplicate, unknown} 

  ASSUME_SORTED:
    inputBinding:
      position: 5
      prefix: "ASSUME_SORTED=true"
      separate: false
    type: boolean?
    doc: |
       If true, assume that the input files are in the same sort order as the requested output sort order, even if their headers say otherwise. Default value: false. This option can be set to 'null' to clear the default value. Possible values: {true, false} 

  MERGE_SEQUENCE_DICTIONARIES:
    inputBinding:
      position: 5
      prefix: "MERGE_SEQUENCE_DICTIONARIES=true"
      separate: false
    type: boolean?
    doc: |
       Merge the sequence dictionaries Default value: false. This option can be set to 'null' to clear the default value. Possible values: {true, false} 

  USE_THREADING:
    inputBinding:
      position: 5
      prefix: "USE_THREADING=true"
      separate: false
    type: boolean?
    doc: |
       Option to create a background thread to encode, compress and write to disk the output file. The threaded version uses about 20% more CPU and decreases runtime by ~20% when writing out a compressed BAM file. Default value: false. This option can be set to 'null' to clear the default value. Possible values: {true, false} 

  COMMENT:
    inputBinding:
      position: 5
      prefix: "COMMENT="
      separate: false
    type: string?
    doc: |
       Comment(s) to include in the merged output file's header. Default value: null. This option may be specified 0 or more times. 

  INTERVALS:
    inputBinding:
      position: 5
      prefix: "INTERVALS="
      separate: false
    type: File?
    doc: |
       An interval list file that contains the locations of the positions to merge. Assume bam are sorted and indexed. The resulting file will contain alignments that may overlap with genomic regions outside the requested region. Unmapped reads are discarded. Default value: null. 

