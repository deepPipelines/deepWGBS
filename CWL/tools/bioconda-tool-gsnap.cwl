cwlVersion: v1.0
class: CommandLineTool



id: "GSNAP"
label: "GSNAP"

cwlVersion: "v1.0"

doc: |
    GSNAP: See the [Gmap](http://research-pub.gene.com/gmap/) webpage for more information.

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
    dockerPull: "quay.io/biocontainers/gmap:2017.10.30--pl5.22.0_1"


requirements:
  - class: InlineJavascriptRequirement

baseCommand: ["gsnap"]

stdout: $( inputs.output_name )

outputs:
  alignment:
    type: stdout
    streamable: true

inputs:

  readfile1:
    streamable: true
    type: File
    inputBinding:
      position: 10

  readfile2:
    streamable: true
    type: File?
    inputBinding:
      position: 15

  output_name:
    type: string

  dir:
    type: Directory?
    inputBinding:
      position: 1
      prefix: --dir=
      separate: false
    doc: |
      Genome directory

  db:
    type: string
    inputBinding:
      position: 1
      prefix: --db=
      separate: false
    doc: |
      Genome database

  kmer:
    type: int?
    inputBinding:
      position: 1
      prefix: --kmer=
      separate: false
    doc: |
      kmer size to use in genome database (allowed values: 16 or less)
        If not specified, the program will find the highest available
        kmer size in the genome database

  basesize:
    type: int?
    inputBinding:
      position: 1
      prefix: --basesize=
      separate: false
    doc: |
      Base size to use in genome database.  If not specified, the program
        will find the highest available base size in the genome database
        within selected k-mer size

  sampling:
    type: int?
    inputBinding:
      position: 1
      prefix: --sampling=
      separate: false
    doc: |
      Sampling to use in genome database.  If not specified, the program
        will find the smallest available sampling value in the genome database
        within selected basesize and k-mer size

  input-buffer-size:
    type: int?
    inputBinding:
      position: 1
      prefix: --input-buffer-size=
      separate: false
    doc: |
      Size of input buffer (program reads this many sequences
        at a time for efficiency) (default 1000)

  barcode-length:
    type: int?
    inputBinding:
      position: 1
      prefix: --barcode-length=
      separate: false
    doc: |
      Amount of barcode to remove from start of read
        (default 0)

  orientation:
    type: string?
    inputBinding:
      position: 1
      prefix: --orientation=
      separate: false
    doc: |
      Orientation of paired-end reads
        Allowed values: FR (fwd-rev, or typical Illumina; default),
        RF (rev-fwd, for circularized inserts), or FF (fwd-fwd, same strand)

  fastq-id-start:
    type: int?
    inputBinding:
      position: 1
      prefix: --fastq-id-start=
      separate: false
    doc: |
      Starting position of identifier in FASTQ header, space-delimited (>= 1)

  fastq-id-end:
    type: int?
    inputBinding:
      position: 1
      prefix: --fastq-id-end=
      separate: false
    doc: |
      Ending position of identifier in FASTQ header, space-delimited (>= 1)

  gunzip:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --gunzip
    doc: |
      Uncompress gzipped input files

  bunzip2:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --bunzip2
    doc: |
      Uncompress bzip2-compressed input files

  batch:
    type:
      - "null"
      - type: enum
        symbols: ["0", "1", "2", "3", "4", "5"]
    inputBinding:
      position: 1
      prefix: --batch=
      separate: false
    doc: |
      Batch mode (default = 2)
                 Mode     Offsets       Positions       Genome
                   0      allocate      mmap            mmap
                   1      allocate      mmap & preload  mmap
      (default)    2      allocate      mmap & preload  mmap & preload
                   3      allocate      allocate        mmap & preload
                   4      allocate      allocate        allocate
                   5      expand        allocate        allocate
      Note, For a single sequence, all data structures use mmap
      If mmap not available and allocate not chosen, then will use fileio (very slow)

  max-mismatches:
    type: float?
    inputBinding:
      position: 1
      prefix: --max-mismatches=
      separate: false
    doc: |
      Maximum number of mismatches allowed (if not specified, then
        defaults to the ultrafast level of ((readlength+index_interval-1)/kmer - 2))
        (By default, the genome index interval is 3, but this can be changed
         by providing a different value for -q to gmap_build when processing
        the genome.)
             If specified between 0.0 and 1.0, then treated as a fraction
        of each read length.  Otherwise, treated as an integral number
        of mismatches (including indel and splicing penalties)
        For RNA-Seq, you may need to increase this value slightly
        to align reads extending past the ends of an exon.

  query-unk-mismatch:
    type: int?
    inputBinding:
      position: 1
      prefix: --query-unk-mismatch=
      separate: false
    doc: |
      Whether to count unknown (N) characters in the query as a mismatch
        (0=no (default), 1=yes)

  genome-unk-mismatch:
    type: int?
    inputBinding:
      position: 1
      prefix: --genome-unk-mismatch=
      separate: false
    doc: |
      Whether to count unknown (N) characters in the genome as a mismatch
        (0=no, 1=yes (default))

  maxsearch:
    type: int?
    inputBinding:
      position: 1
      prefix: --maxsearch=
      separate: false
    doc: |
      Maximum number of alignments to find (default 1000).
        Must be larger than --npaths, which is the number to report.
        Keeping this number large will allow for random selection among multiple alignments.
        Reducing this number can speed up the program.

  terminal-threshold:
    type: int?
    inputBinding:
      position: 1
      prefix: --terminal-threshold=
      separate: false
    doc: |
      Threshold for searching for a terminal alignment (from one end of the
        read to the best possible position at the other end) (default 2
        for standard, atoi-stranded, and atoi-nonstranded mode; default 100
        for cmet-stranded and cmet-nonstranded mode).
        For example, if this value is 2, then if GSNAP finds an exact or
        1-mismatch alignment, it will not try to find a terminal alignment.
        Note that this default value may not be low enough if you want to
        obtain terminal alignments for very short reads, although such reads
        probably don't have enough specificity for terminal alignments anyway.
        To turn off terminal alignments, set this to a high value, greater
        than the value for --max-mismatches.

  indel-penalty:
    type: int?
    inputBinding:
      position: 1
      prefix: --indel-penalty=
      separate: false
    doc: |
      Penalty for an indel (default 2). 

  indel-endlength:
    type: int?
    inputBinding:
      position: 1
      prefix: --indel-endlength=
      separate: false
    doc: |
      Minimum length at end required for indel alignments (default 4) 

  max-middle-insertions:
    type: int?
    inputBinding:
      position: 1
      prefix: --max-middle-insertions=
      separate: false
    doc: |
      Maximum number of middle insertions allowed (default 9) 

  max-middle-deletions:
    type: int?
    inputBinding:
      position: 1
      prefix: --max-middle-deletions=
      separate: false
    doc: |
      Maximum number of middle deletions allowed (default 30) 

  max-end-insertions:
    type: int?
    inputBinding:
      position: 1
      prefix: --max-end-insertions=
      separate: false
    doc: |
      Maximum number of end insertions allowed (default 3) 

  max-end-deletions:
    type: int?
    inputBinding:
      position: 1
      prefix: --max-end-deletions=
      separate: false
    doc: |
      Maximum number of end deletions allowed (default 6) 

  suboptimal-levels:
    type: int?
    inputBinding:
      position: 1
      prefix: --suboptimal-levels=
      separate: false
    doc: |
      Report suboptimal hits beyond best hit (default 0) 

  adapter-strip:
    type: string?
    inputBinding:
      position: 1
      prefix: --adapter-strip=
      separate: false
    doc: |
      Method for removing adapters from reads. Currently allowed values: off, paired. 

  trim-mismatch-score:
    type: int?
    inputBinding:
      position: 1
      prefix: --trim-mismatch-score=
      separate: false
    doc: |
      Score to use for mismatches when trimming at ends (default is -3; 
        to turn off trimming, specify 0).  Warning: turning trimming off
        will give false positive mismatches at the ends of reads

  trim-indel-score:
    type: int?
    inputBinding:
      position: 1
      prefix: --trim-indel-score=
      separate: false
    doc: |
      Score to use for indels when trimming at ends (default is -4; 
        to turn off trimming, specify 0).  Warning: turning trimming off
        will give false positive indels at the ends of reads

  snpsdir:
    type: string?
    inputBinding:
      position: 1
      prefix: --snpsdir=
      separate: false
    doc: |
      Directory for SNPs index files (created using snpindex) (default is -4;
        to turn off trimming, specify 0).  Warning: turning trimming off
        will give false positive indels at the ends of reads

  use-snps:
    type: string?
    inputBinding:
      position: 1
      prefix: --use-snps=
      separate: false
    doc: |
      Use database containing known SNPs (in <STRING>.iit, built previously using snpindex) for tolerance to SNPs

  cmetdir:
    type: string?
    inputBinding:
      position: 1
      prefix: --cmetdir=
      separate: false
    doc: |
      Directory for methylcytosine index files (created using cmetindex) (default is location of genome index files specified using -D, -V, and -d)

  atoidir:
    type: string?
    inputBinding:
      position: 1
      prefix: --atoidir=
      separate: false
    doc: |
      Directory for A-to-I RNA editing index files (created using atoiindex) (default is location of genome index files specified using -D, -V, and -d)

  mode:
    type: 
      - "null"
      - type: enum
        symbols: [ standard, cmet-stranded, cmet-nonstranded, atoi-stranded, atoi-nonstranded ]
    inputBinding:
      position: 1
      prefix: --mode=
      separate: false
    doc: |
      Alignment mode: standard (default), cmet-stranded, cmet-nonstranded, 
        atoi-stranded, or atoi-nonstranded.  Non-standard modes requires you
        to have previously run the cmetindex or atoiindex programs on the genome

  tallydir:
    type: string?
    inputBinding:
      position: 1
      prefix: --tallydir=
      separate: false
    doc: |
      Directory for tally IIT file to resolve concordant multiple results (default is 
        location of genome index files specified using -D and -d).  Note: can
        just give full path name to --use-tally instead.

  use-tally:
    type: string?
    inputBinding:
      position: 1
      prefix: --use-tally=
      separate: false
    doc: |
      Use this tally IIT file to resolve concordant multiple results 

  runlengthdir:
    type: string?
    inputBinding:
      position: 1
      prefix: --runlengthdir=
      separate: false
    doc: |
      Directory for runlength IIT file to resolve concordant multiple results (default is
        location of genome index files specified using -D and -d).  Note: can
        just give full path name to --use-runlength instead.

  use-runlength:
    type: string?
    inputBinding:
      position: 1
      prefix: --use-runlength=
      separate: false
    doc: |
      Use this runlength IIT file to resolve concordant multiple results 

  nthreads:
    type: int?
    inputBinding:
      position: 1
      prefix: --nthreads=
      separate: false
    doc: |
      Number of worker threads 

  gmap-mode:
    type: string?
    inputBinding:
      position: 1
      prefix: --gmap-mode=
      separate: false
    doc: |
      Cases to use GMAP for complex alignments containing multiple splices or indels
        Allowed values: none, pairsearch, indel_knownsplice, terminal, improve
        (or multiple values, separated by commas).
        Default: all on, i.e., pairsearch,indel_knownsplice,terminal,improve

  trigger-score-for-gmap:
    type: int?
    inputBinding:
      position: 1
      prefix: --trigger-score-for-gmap=
      separate: false
    doc: |
      Try GMAP pairsearch on nearby genomic regions if best score (the total
        of both ends if paired-end) exceeds this value (default 5)

  gmap-min-match-length:
    type: int?
    inputBinding:
      position: 1
      prefix: --gmap-min-match-length=
      separate: false
    doc: |
      Keep GMAP hit only if it has this many consecutive matches (default 20) 

  max-gmap-pairsearch:
    type: int?
    inputBinding:
      position: 1
      prefix: --max-gmap-pairsearch=
      separate: false
    doc: |
      Perform GMAP pairsearch on nearby genomic regions up to this many
        many candidate ends (default 10).  Requires pairsearch in --gmap-mode

  max-gmap-terminal:
    type: int?
    inputBinding:
      position: 1
      prefix: --max-gmap-terminal=
      separate: false
    doc: |
      Perform GMAP terminal on nearby genomic regions up to this many 
        candidate ends (default 5).  Requires terminal in --gmap-mode

  max-gmap-improvement:
    type: int?
    inputBinding:
      position: 1
      prefix: --max-gmap-improvement=
      separate: false
    doc: |
      Perform GMAP improvement on nearby genomic regions up to this many 
        candidate ends (default 5).  Requires improve in --gmap-mode

  microexon-spliceprob:
    type: float?
    inputBinding:
      position: 1
      prefix: --microexon-spliceprob=
      separate: false
    doc: |
      Allow microexons only if one of the splice site probabilities is 
        greater than this value (default 0.90)

  novelsplicing:
    type: int?
    inputBinding:
      position: 1
      prefix: --novelsplicing=
      separate: false
    doc: |
       Look for novel splicing (0=no (default), 1=yes)

  splicingdir:
    type: string?
    inputBinding:
      position: 1
      prefix: --splicingdir=
      separate: false
    doc: |
      Directory for splicing involving known sites or known introns, 
        as specified by the -s or --use-splicing flag (default is
        directory computed from -D and -d flags).  Note: can
        just give full pathname to the -s flag instead.

  use-splicing:
    type: string?
    inputBinding:
      position: 1
      prefix: --use-splicing=
      separate: false
    doc: |
      Look for splicing involving known sites or known introns 
        (in <STRING>.iit), at short or long distances
        See README instructions for the distinction between known sites
        and known introns

  ambig-splice-noclip:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --ambig-splice-noclip
    doc: |
      For ambiguous known splicing at ends of the read, do not clip at the 
        splice site, but extend instead into the intron.  This flag makes
        sense only if you provide the --use-splicing flag, and you are trying
        to eliminate all soft clipping with --trim-mismatch-score=0

  localsplicedist:
    type: int?
    inputBinding:
      position: 1
      prefix: --localsplicedist=
      separate: false
    doc: |
      Definition of local novel splicing event (default 200000) 

  novelend-splicedist:
    type: int?
    inputBinding:
      position: 1
      prefix: --novelend-splicedist=
      separate: false
    doc: |
      Distance to look for novel splices at the ends of reads (default 50000) 

  local-splice-penalty:
    type: int?
    inputBinding:
      position: 1
      prefix: --local-splice-penalty=
      separate: false
    doc: |
      Penalty for a local splice (default 0). Counts against mismatches allowed 

  distant-splice-penalty:
    type: int?
    inputBinding:
      position: 1
      prefix: --distant-splice-penalty=
      separate: false
    doc: |
      Penalty for a distant splice (default 1). A distant splice is one where 
        the intron length exceeds the value of -w, or --localsplicedist, or is an
        inversion, scramble, or translocation between two different chromosomes
        Counts against mismatches allowed

  distant-splice-endlength:
    type: int?
    inputBinding:
      position: 1
      prefix: --distant-splice-endlength=
      separate: false
    doc: |
      Minimum length at end required for distant spliced alignments (default 16, min 
        allowed is the value of -k, or kmer size)

  shortend-splice-endlength:
    type: int?
    inputBinding:
      position: 1
      prefix: --shortend-splice-endlength=
      separate: false
    doc: |
      Minimum length at end required for short-end spliced alignments (default 2, 
        but unless known splice sites are provided with the -s flag, GSNAP may still
        need the end length to be the value of -k, or kmer size to find a given splice

  distant-splice-identity:
    type: float?
    inputBinding:
      position: 1
      prefix: --distant-splice-identity=
      separate: false
    doc: |
       Minimum identity at end required for distant spliced alignments (default 0.95) 

  antistranded-penalty:
    type: int?
    inputBinding:
      position: 1
      prefix: --antistranded-penalty=
      separate: false
    doc: |
      (Not currently implemented) 
        Penalty for antistranded splicing when using stranded RNA-Seq protocols.
        A positive value, such as 1, expects antisense on the first read
        and sense on the second read.  Default is 0, which treats sense and antisense
        equally well

  merge-distant-samechr:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --merge-distant-samechr
    doc: |
      Report distant splices on the same chromosome as a single splice, if possible. 
        Will produce a single SAM line instead of two SAM lines, which is also done
        for translocations, inversions, and scramble events

  pairmax-dna:
    type: int?
    inputBinding:
      position: 1
      prefix: --pairmax-dna=
      separate: false
    doc: |
      Max total genomic length for DNA-Seq paired reads, or other reads 
        without splicing (default 1000).  Used if -N or -s is not specified.

  pairmax-rna:
    type: int?
    inputBinding:
      position: 1
      prefix: --pairmax-rna=
      separate: false
    doc: |
      Max total genomic length for RNA-Seq paired reads, or other reads 
        that could have a splice (default 200000).  Used if -N or -s is specified.
        Should probably match the value for -w, --localsplicedist.

  quality-protocol:
    type: 
      - "null"
      - type: enum
        symbols: [illumina, sanger]
    inputBinding:
      position: 1
      prefix: --quality-protocol=
      separate: false
    doc: |
      Protocol for input quality scores. Allowed values: 
          illumina (ASCII 64-126) (equivalent to -J 64 -j -31)
          sanger   (ASCII 33-126) (equivalent to -J 33 -j 0)
        Default is sanger (no quality print shift)
        SAM output files should have quality scores in sanger protocol

  quality-zero-score:
    type: int?
    inputBinding:
      position: 1
      prefix: --quality-zero-score=
      separate: false
    doc: |
      FASTQ quality scores are zero at this ASCII value 
        (default is 33 for sanger protocol; for Illumina, select 64)

  quality-print-shift:
    type: int?
    inputBinding:
      position: 1
      prefix: --quality-print-shift=
      separate: false
    doc: |
      Shift FASTQ quality scores by this amount in output 
        (default is 0 for sanger protocol; to change Illumina input
        to Sanger output, select -31)

  npaths:
    type: int?
    inputBinding:
      position: 1
      prefix: --npaths=
      separate: false
    doc: |
      Maximum number of paths to print (default 100). 

  quiet-if-excessive:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --quiet-if-excessive
    doc: |
      If more than maximum number of paths are found, 
        then nothing is printed.

  ordered:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --ordered
    doc: |
      Print output in same order as input (relevant 
        only if there is more than one worker thread)

  show-refdiff:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --show-refdiff
    doc: |
      For GSNAP output in SNP-tolerant alignment, shows all differences 
        relative to the reference genome as lower case (otherwise, it shows
        all differences relative to both the reference and alternate genome)

  clip-overlap:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --clip-overlap
    doc: |
      For paired-end reads whose alignments overlap, clip the overlapping region. 

  print-snps:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --print-snps
    doc: |
      Print detailed information about SNPs in reads (works only if -v also selected) 
        (not fully implemented yet)

  failsonly:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --failsonly
    doc: |
      Print only failed alignments, those with no results 

  nofails:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --nofails
    doc: |
      Exclude printing of failed alignments 

  fails-as-input:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --fails-as-input
    doc: |
      Print completely failed alignments as input FASTA or FASTQ format 

  format:
    type: string?
    inputBinding:
      position: 1
      prefix: --format=
      separate: false
    doc: |
      Another format type, other than default.
        Currently implemented: sam
        Also allowed, but not installed at compile-time: goby
        (To install, need to re-compile with appropriate options)

  split-output:
    type: string?
    inputBinding:
      position: 1
      prefix: --split-output=
      separate: false
    doc: |
      Basename for multiple-file output, separately for nomapping, 
        halfmapping_uniq, halfmapping_mult, unpaired_uniq, unpaired_mult,
        paired_uniq, paired_mult, concordant_uniq, and concordant_mult results (up to 9 files,
        or 10 if --fails-as-input is selected, or 3 for single-end reads)

  append-output:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --append-output
    doc: |
      When --split-output is given, this flag will append output to the 
        existing files.  Otherwise, the default is to create new files.

  output-buffer-size:
    type: int?
    inputBinding:
      position: 1
      prefix: --output-buffer-size=
      separate: false
    doc: |
      Buffer size, in queries, for output thread (default 1000). When the number 
        of results to be printed exceeds this size, the worker threads are halted
        until the backlog is cleared

  no-sam-headers:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --no-sam-headers
    doc: |
      Do not print headers beginning with '@'

  sam-headers-batch:
    type: int?
    inputBinding:
      position: 1
      prefix: --sam-headers-batch=
      separate: false
    doc: |
      Print headers only for this batch, as specified by -q 

  sam-use-0M:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --sam-use-0M
    doc: |
      Insert 0M in CIGAR between adjacent insertions and deletions 
        Required by Picard, but can cause errors in other tools

  sam-multiple-primaries:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --sam-multiple-primaries
    doc: |
      Allows multiple alignments to be marked as primary if they 
        have equally good mapping scores

  force-xs-dir:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --force-xs-dir
    doc: |
      For RNA-Seq alignments, disallows XS:A:? when the sense direction
        is unclear, and replaces this value arbitrarily with XS:A:+.
        May be useful for some programs, such as Cufflinks, that cannot
        handle XS:A:?.  However, if you use this flag, the reported value
        of XS:A:+ in these cases will not be meaningful.

  md-lowercase-snp:
    type: boolean?
    inputBinding:
      position: 1
      prefix: --md-lowercase-snp
    doc: |
      In MD string, when known SNPs are given by the -v flag, 
        prints difference nucleotides as lower-case when they,
        differ from reference but match a known alternate allele

  read-group-id:
    type: string?
    inputBinding:
      position: 1
      prefix: --read-group-id=
      separate: false
    doc: |
       Value to put into read-group id (RG-ID) field 

  read-group-name:
    type: string?
    inputBinding:
      position: 1
      prefix: --read-group-name=
      separate: false
    doc: |
       Value to put into read-group name (RG-SM) field 

  read-group-library:
    type: string?
    inputBinding:
      position: 1
      prefix: --read-group-library=
      separate: false
    doc: |
       Value to put into read-group library (RG-LB) field 

  read-group-platform:
    type: string?
    inputBinding:
      position: 1
      prefix: --read-group-platform=
      separate: false
    doc: |
       Value to put into read-group library (RG-PL) field 




$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
  - https://schema.org/docs/schema_org_rdfa.html
  - http://edamontology.org/EDAM_1.18.owl 

