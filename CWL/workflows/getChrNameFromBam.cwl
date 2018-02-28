cwlVersion: v1.0
class: Workflow

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström

outputs:

  chrNames:
    type: string[]
    outputSource: convertToArray/lines

inputs:

  input:
    type: File

steps:
  getHeader:
    run: ../tools/localfile-tool-getChrName.cwl
    in:
      input: input
      output_name:
        valueFrom: "chrList.txt"
    out:
      - chrNames

  convertToArray:
    run: ../tools/localfile-expressionTool-getLinesFromFile.cwl
    in:
      inputFile: getHeader/chrNames
    out:
      - lines
      

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
