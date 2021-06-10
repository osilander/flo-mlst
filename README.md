# flo-mlst
Code to analyse multiplexed mlst amplicons

MLST amplicons are usually amplified singly and Sanger sequenced for economy. However, it 
may be simpler and faster to amplify these in a multiplexed fashion and then sequence 
them on an NGS platform. The code here accepts fastq from a multiplexed (e.g. RBK) sets of amplicons 
(e.g. from a flongle run), demultiplexes the reads, performs trimming, maps the reads back onto
 a fasta file containing a reference set of MLST loci, separates the input reads by the amplicons 
 that they map to, and then uses the reference amplicons to produce a set of variant-called amplicons for each sample.
 These are then concatenated, together with a similar set of reference MLST loci, 
 and a single splitstree is output, which contans the reference set of strains and the strains from the 
 fastq readset.


