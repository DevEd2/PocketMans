#!/bin/sh

echo "Converting mans front sprites..."
cd GFX/Mans/Front
for file in *.png; do
    rgbgfx $file -o $file.tmp
    python3 ../../../Tools/wlenc.py $file.tmp $file.wle
    rm $file.tmp
done
cd ../Back
echo "Converting mans back sprites..."
for file in *.png; do
    rgbgfx $file -o $file.tmp
    python3 ../../../Tools/wlenc.py $file.tmp $file.wle
    rm $file.tmp
done
cd ../../..