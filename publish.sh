#!/bin/bash

function publish(){
    base=`basename $name`
    if [[ !("$base" =~ (.*~)) ]] && [ $base != "publish.sh" ];  then
       cp -vb $name ~/.$base 
    fi

}

for name in ./*; do publish; done

