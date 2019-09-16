#!/bin/bash
git submodule update --init --recursive

if test -e build; then
    echo 'build dir already exists;'
    make clean
    make -j8
else
    mkdir build
    cd build
    cmake -DBOOST_J=$(nproc) $ARGS "$@" ..
    make -j8
fi