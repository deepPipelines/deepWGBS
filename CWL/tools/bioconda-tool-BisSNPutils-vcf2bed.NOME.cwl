#!/usr/bin/env cwl-runner

class: CommandLineTool

id: "Bis-SNP_vcf2bed.NOME"
label: "Bis-SNP vcf2bed NOME"

cwlVersion: "v1.0"

doc: |
    ![build_status](https://quay.io/repository/karl616/dockstore-tool-bissnp/status)
    A Docker container containing the Bis-SNP utility scripts. See the [Bis-SNP](http://people.csail.mit.edu/dnaase/bissnp2011/) webpage for more information.

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
    dockerPull: "quay.io/biocontainers/bis-snp-utils:0.0.1--pl5.22.0_0"

baseCommand: ["vcf2bed.NOME.pl"]

stdout: $( outputName )

outputs:
  
  CpGbed:
    type: stdout

inputs:
  outputName:
    type: string
    doc: |
      File name to use for the output file

  input:
    inputBinding:
      position: 10
    type: File
    doc: |
      input file to convert

  context:
    inputBinding:
      position: 20
    type: string?
    doc: |
      context to extract (default: CG)

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl
