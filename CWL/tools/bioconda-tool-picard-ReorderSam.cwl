#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "Picard_ReorderSam"
label: "Picard ReorderSam"

cwlVersion: "v1.0"

doc: |
    ![build_status](https://quay.io/repository/karl616/dockstore-tool-picard/status)
    A Docker container containing the Picard jar file. See the [Picard](http://broadinstitute.github.io/picard/) webpage for more information.

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
    dockerPull: "quay.io/biocontainers/picard:2.17.2--py36_0"

baseCommand: ["picard", "ReorderSam"]

outputs:

  OUTPUT_output:
    type: File
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
      prefix: "INPUT="
      separate: false
    type: File
    doc: |
       Input file (SAM or BAM) to extract reads from. Required. 

  OUTPUT:
    inputBinding:
      position: 5
      prefix: "OUTPUT="
      separate: false
    type: string
    doc: |
       Output file (SAM or BAM) to write extracted reads to. Required. 

  ALLOW_INCOMPLETE_DICT_CONCORDANCE:
    inputBinding:
      position: 5
      prefix: "ALLOW_INCOMPLETE_DICT_CONCORDANCE=true"
      separate: false
    type: boolean?
    doc: |
       If true, then allows only a partial overlap of the original contigs with the new reference sequence contigs. By default, this tool requires a corresponding contig in the new reference for each read contig Default value: false. This option can be set to 'null' to clear the default value. Possible values: {true, false} 

  ALLOW_CONTIG_LENGTH_DISCORDANCE:
    inputBinding:
      position: 5
      prefix: "ALLOW_CONTIG_LENGTH_DISCORDANCE=true"
      separate: false
    type: boolean?
    doc: |
       If true, then permits mapping from a read contig to a new reference contig with the same name but a different length. Highly dangerous, only use if you know what you are doing. Default value: false. This option can be set to 'null' to clear the default value. Possible values: {true, false} 

  REFERENCE:
    inputBinding:
      position: 5
      prefix: "REFERENCE="
      separate: false
    type: File
    doc: |
       Reference sequence to reorder reads to match. A sequence dictionary corresponding to the reference fasta is required. Create one with CreateSequenceDictionary. Required. 

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
