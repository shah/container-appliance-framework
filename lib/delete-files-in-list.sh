#!/bin/bash

if [ -z "$1" ]; then
    echo "A source file was expected as the first parameter."
    exit 1
fi

SRC_FILE=$1
if [ ! -f $SRC_FILE ]; then
    echo "Source file $SRC_FILE not found."
    exit 2
fi

while IFS= read -r file
do
    [ -f "$file" ] && echo "Deleted $file specified in $SRC_FILE" && rm -f $file
done < "$SRC_FILE"
