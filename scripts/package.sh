#!/bin/bash

echo "Creating folder..."
mkdir cars
echo "Created cars folder"

for file in $(find . -iname *.car); do
  echo "Processing file ${file}"
  cp $file cars/${file##*/}; 
done

for f in $(ls cars); do 

  echo "Adding ${file} to manifest"
  echo $f >> cars/manifest.list;
  
done
