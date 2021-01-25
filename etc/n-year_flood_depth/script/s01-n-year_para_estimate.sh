#!/bin/sh
VAR=$1
CAMA_FOLDER=$2
GLBNAMES=$3
FUNC=$4
YEARS=$5
YEARE=$6
RES=$7


for GLBNAME in $GLBNAMES
do
    INPDIR=$CAMA_FOLDER'/out/'${GLBNAME} # input directory
    MAPDIR=$CAMA_FOLDER'/map/glb_15min' # map directory

    EXPNAME=$EXPNAME-$RES

    # '' > no normorlization
    # "
    norm=''

    # define the output folder
    if [ $VAR == 'rivdph' ] ; then
        OUTDIR="./../result"$norm"/"${GLBNAME}"/"
    else
        OUTDIR="./../result"$norm"/"${GLBNAME}"/STO2DPH"
    fi


    mkdir -p $OUTDIR
    ln -snf $MAPDIR ${OUTDIR}/map
    ln -snf $MAPDIR map
    ln -snf $INPDIR ${OUTDIR}/inp

    # calculate the x,y information from the map parameters
    XSIZE=$(head -n 1 "${MAPDIR}/params.txt" | awk '{print $1}') # xsize of input data
    YSIZE=$(head -n 2 "${MAPDIR}/params.txt" | tail -n 1 | awk '{print $1}') # ysize of input data

    echo "\nYEARS=${YEARS}, YEARE=${YEARE}, YSIZE=${YSIZE}, XSIZE=${XSIZE}"
    echo "INPDIR=${INPDIR}"
    echo "MAPDIR=${MAPDIR}"


    ##### Main calculation ##########################

    echo '\n### calculate annual maximum value ###'
    mkdir -p ${OUTDIR}/amax
    python ./src/annual_max.py $YEARS $YEARE $YSIZE $XSIZE $OUTDIR $VAR

    ####
    for fun in $FUNC
    do 
        echo '\n### calculate and store the parameter, also the statistics for the fitting###'

        echo `ls './../result/'$GLBNAME/para/$fun* | grep $fun | wc -l  `
        paranum=`ls './../result/'$GLBNAME/para/$fun* | grep $fun | wc -l  `
        

        if [ $paranum -gt 0 ]; then
            echo "$GLBNAME $fun exists"
            python ./src/calc_distributions.py $YEARS $YEARE $YSIZE $XSIZE $OUTDIR $VAR $fun $norm #&

        else
            echo $GLBNAME $fun 
            mkdir -p ${OUTDIR}/para
            python ./src/calc_distributions.py $YEARS $YEARE $YSIZE $XSIZE $OUTDIR $VAR $fun $norm #&

        # controlling of the parallization.
        #NUM1=`ps aux | grep calc_distributions  | wc -l | awk '{print $1}'`
        #while [ $NUM1 -gt 18 ];
        #do
        #  sleep 30
        #  NUM1=`ps aux | grep calc_distributions  | wc -l | awk '{print $1}'`
        #done
        fi 

    done

done

