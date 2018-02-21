cwlVersion: v1.0
class: Workflow

dct:creator:
  "@id": "https://orcid.org/0000-0001-6231-4417"
  foaf:name: Karl Nordström
  foaf:mbox: "mailto:karl.nordstroem@uni-saarland.de"

outputs:

  indexedFile:
    type: File
    secondaryFiles:
      - ".tbi"
    outputSource: index/indexedFile

inputs:

  input:
    type: File
    streamable: true

  filetype:
    type:
      - 'null'
      - type: enum
        symbols: [gff, bed, sam, vcf, psltbl]

  outputName:
    type: string


steps:
  compress:
    run: ../tools/bioconda-tool-bgzip.cwl
    in:
      input: input
      output_name: outputName
    out:
      - bgzippedFile

  index:
    run: ../tools/bioconda-tool-tabix.cwl
    in:
      input: compress/bgzippedFile
      preset: filetype
      skip:
        valueFrom: $( filetype == "bed"?1:0 )
    out:
      - indexedFile
      

