cwlVersion: v1.0
class: Workflow

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström

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
      

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
