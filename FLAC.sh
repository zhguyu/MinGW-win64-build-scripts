#!/bin/bash
# FLAC encoder building script
# Author: Guang Yu, ZHANG (Anthony)
# Created: Dec 21, 2021
rm -rf flac
git clone https://github.com/xiph/flac.git
cd flac
./autogen.sh
CFLAGS="-O3 -DNDEBUG -funroll-loops -ffast-math -fstack-protector -flto" \
CXXFLAGS="-O3 -DNDEBUG -ffast-math -fstack-protector -flto" \
    ./configure --disable-shared \
                --enable-static \
                --enable-64-bit-words \
                --disable-ogg \
                --disable-xmms-plugin \
                --disable-rpath \
                --disable-examples
# Makefile uses libtool for linking, so -all-static instead of -static should be specified.
# However above flag cannot be recognized by gcc when 'configure' checks for the compiler
# by attempting to compile a dummy program, and gcc would throw an error, making 'configure'
# believe the compiler is not working.
# Thus, we can't specify LDFLAGS, and should instead perform the following string replacement.
sed -i 's/LDFLAGS = /LDFLAGS = -s -all-static/g' src/flac/Makefile
sed -i 's/LDFLAGS = /LDFLAGS = -s -all-static/g' src/metaflac/Makefile
make
mv src/metaflac/metaflac.exe src/flac
