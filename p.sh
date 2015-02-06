#!/bin/bash

inputFile=/root/work/tex/source/tiku_tex.txt
baseFolder=/root/work/tex

errorCount=0
successCount=0

init() {
    cd $baseFolder
    rm -rf tmp
    mkdir -p out/results out/errors tmp
}

clean() {
    rm -rf tmp
}

createPNG() {
    mkdir -p tmp/out
    rm -rf tmp/out/*

    sed -e "s/FORMULA_VALUE/$(echo $3 | sed -e 's/\\/\\\\/g' -e 's/\//\\\//g' -e 's/&/\\\&/g')/g" -e "s/COLOR_VALUE/$4/g" base/base.tex > tmp/formula.tex

    ff="$(echo $2)_$(echo $4 | cut -c1)" 
    png="$1/$ff.png"
    pdflatex -halt-on-error -output-directory tmp/out tmp/formula > /dev/null 2>&1 
    if [ $PIPESTATUS = "0" ]; then
        {
            mkdir -p out/results/$1
            convert -density 300 tmp/out/formula.pdf out/results/$png
            successCount=$((successCount + 1))
            echo $png
        }
    else
        {
            mv tmp/out/formula.log out/errors/$ff.log
            errorCount=$((errorCount + 1))
            echo fail
        }
    fi
 
}

generate() {
    readarray a < $inputFile    
    for line in "${a[@]}"
        do {
            folder=`echo $line | sed "s/<tiku>/\t/g" | cut -f2`
            name=`echo $line | sed "s/<tiku>/\t/g" | cut -f3`
            formula=`echo $line | sed "s/<tiku>/\t/g" | cut -f4`

            createPNG $folder $name "$formula" black
            createPNG $folder $name "$formula" white
        }
    done
}

process() {
    start=$(date +%s)

    init
    generate
    clean

    end=$(date +%s)
    diff=$(($end - $start))

    echo -------------------------
    echo generated $successCount images with $errorCount errors in $diff seconds
}

process
