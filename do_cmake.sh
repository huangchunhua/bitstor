#!/bin/bash
git submodule update --init --recursive

if test -e build; then
    echo 'build dir already exists; rm -rf build'
    rm -rf build
fi

if test -e product; then
    echo 'product dir already exists; rm -rf output'
    rm -rf product
fi

mkdir build
cd build
cmake -DBOOST_J=$(nproc) $ARGS "$@" ..

make clean
make -j8
