#!usr/bin/env cwl-runner

class: CommandLineTool

id: "genMetaBed"
label: "genMetaBed"

cwlVersion: "v1.0"

doc: |
    Generates meta data from a .bed file

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0001-6231-4417
    s:email: mailto:karl.nordstroem@uni-saarland.de
    s:name: Karl Nordstroem

s:contributor:
   class: s:Person
   s:identifier: https://orcid.org/0000-0003-1381-257X
   s:email: mailto:dania.humaidan@gmail.com
   s:name: Dania Humaidan


requirements::
  - class: InitialWorkDirRequirement
    listing:
      - inputs.scriptFolder

hints:
  - class: ResourceRequirement
    coresMin: 1
    ramMin: 4092
    outdirMin: 512000
  - class: DockerRequirement
    dockerPull: "quay.io/biocontainers/bis-snp-utils:0.0.1--pl5.22.0_0"


baseCommand: ["bash", inputs.scriptFolder.basename +"/genMetaBed"]

stdout: $( inputs.output_name + '.txt')

outputs:
  metadata :
    type: stdout
 
  methFile:
   type: File
   outputBinding:
    glob: $(input.output_name + '.cpg.filtered.strandBias.meth.png')

  covFile:
    type: File
    outputBinding:
     glob: $(input.output_name + '.cpg.filtered.strandBias.cov.png')

inputs:

  CPG_ISLANDS:
    type: File
    inputBinding:
     position: 1
     prefix: -s

  bedFile:
    type: File
    inputBinding:
     position: 2
     prefix: -b

  output_name:
    type: string
    inputBinding:
     position: 3
     prefix: -o
    doc: |
      Name of output file

  scriptFolder:
    type: Directory
    doc: |
      folder containing associated scripts

$namespaces:
  s: http://schema.org/
  edam: http://edamontology.org/

$schemas:
 - http://schema.org/docs/schema_org_rdfa.html
 - http://edamontology.org/EDAM_1.18.owl


