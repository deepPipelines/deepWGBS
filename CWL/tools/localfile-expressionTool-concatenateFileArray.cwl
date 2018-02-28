cwlVersion: v1.0
class: ExpressionTool

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordström

requirements:
- class: InlineJavascriptRequirement

inputs:
  array1: File[]
  array2: File[]

outputs:
  arrayOut: File[]

expression: |
  ${
    return {"arrayOut":inputs.array1.concat(inputs.array2)};
  }

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl

