#!/bin/bash 

mkdir cars
for file in $(find . -iname *.car); do cp $file cars/${file##*/}; done
for f in $(ls cars); do echo $f >> cars/manifest.list; done

