#!/bin/bash
#如果需要使用gcc482 ，请打开下面export的注释：
#这个gcc4.8.2是之前产品线做的包，不是ep做的包，并不建议使用，如果要使用gcc4.8，建议选择centos7.2上系统自带的
#export PATH=/usr/local/gcc/bin:$PATH
#
#请在Makefile中创建output目录，并将欲上线的产出放到output目录下，包括control.sh部署脚本
#请在make clean的时候清除output目录
git submodule update --init --recursive
#yum install -y libuuid-devel
#yum install -y librados2-devel

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
