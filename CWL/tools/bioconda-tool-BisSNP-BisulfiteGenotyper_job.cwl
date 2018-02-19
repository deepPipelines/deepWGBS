input_file:
  class: File
  path: chr17.bam
intervals: "17"
reference_sequence:
  class: File
  path: /projects/references/mm10/GRCm38mm10_PhiX_Lambda.fa
dbSNP:
  class: File
  path: dbSNP138.nucleotideVariations.sorted.vcf
num_threads: 8
output_modes: EMIT_VARIANT_AND_CYTOSINES
standard_min_confidence_threshold_for_emitting: 0
validation_strictness: LENIENT
cytosine_contexts_acquired: 
  - "CG,1"
  - "CA,1"
  - "CC,1"
  - "CT,1"
  - "CAG,1"
  - "CHH,1"
  - "CHG,1"
  - "GC,2"
  - "GCH,2"
  - "GCG,2"
  - "HCG,2"
  - "HCH,2"
  - "HCA,2"
  - "HCC,2"
  - "HCT,2"
