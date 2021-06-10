for S in barcode08 barcode07 barcode06 strain_120501-1/6M strain_120501-3/6M strain_4R4 strain_7A1 strain_7R1 strain_8I2 strain_12A strain_13/1 strain_21/1 strain_32G strain_33/1 strain_43M3 strain_83M4 strain_A2-309 strain_A2-362 strain_ATCC_334 strain_ASCC_428 strain_ASCC_477 strain_ASCC_1087 strain_ASCC_1088 strain_ASCC_1123 strain_BI0231 strain_CRF28 strain_DPC_3968 strain_DPC_3971 strain_DPC_4108 strain_DPC_4249 strain_DPC_4748 strain_L3 strain_L6 strain_L9 strain_L14 strain_L19 strain_L25 strain_L30 strain_M36 strain_MI280 strain_USDA-P strain_UW-1 strain_UW-4

do
    echo $S
    echo -ne '>' >> full.aln
    echo $S >> full.aln
    for F in ftsZ.fas metRS.fas mutL.fas nrdD.fas pgm.fas polA.fas
    do 
        grep -A 1 $S $F | tail -1 >> full.aln
    done
done
