#!/bin/bash

function publish(){
    base=`basename $name`
    if [ $base != "publish.sh" ] && [ $base != *~ ];  then
       cp -vb $name ~/.$base 
    fi

}

for name in ./*; do publish; done

