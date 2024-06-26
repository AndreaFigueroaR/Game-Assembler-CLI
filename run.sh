#!/bin/bash

# Create out folder
mkdir -p build

# Clean out folder
rm -f build/*

# NASM
for file in *.asm; do
    filename=$(basename -- "$file" .asm)
    nasm -F dwarf -f elf64 -o "build/${filename}.o" "$file"
done

# GCC
gcc -no-pie build/*.o -o build/main

# RUN
./build/main
