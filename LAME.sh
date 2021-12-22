#!/bin/bash
# LAME MP3 encoder building script
# Author: Guang Yu, ZHANG (Anthony)
# Created: Dec 20, 2021
rm -rf lame
svn checkout https://svn.code.sf.net/p/lame/svn/trunk/lame lame
cd lame
autoreconf -Wnone
# Assembly code is for i386 only, --enable-nasm will be ignored for x86_64 target
CFLAGS="-O3 -DNDEBUG -ffast-math -flto" \
    ./configure --disable-shared \
                --enable-static \
                --enable-nasm \
                --disable-decoder \
                --disable-rpath \
                --disable-analyzer-hooks
# The GNU configure and makefile won't link the Windows resources into the final executable
# Thus we manually compile the .rc resource file and add it to the linking stage
libtool --tag=RC --mode=compile windres --target=pe-x86-64 -o lameres.lo libmp3lame/lame.rc
sed -i 's|timestatus.$(OBJEXT)|timestatus.$(OBJEXT) ../lameres.$(OBJEXT)|g' frontend/Makefile
# Makefile uses libtool for linking, so -all-static instead of -static should be specified.
# However above flag cannot be recognized by gcc when 'configure' checks for the compiler
# by attempting to compile a dummy program, and gcc would throw an error, making 'configure'
# believe the compiler is not working.
# Thus, we can't specify LDFLAGS, and should instead perform the following string replacement.
sed -i 's|LDFLAGS =   -static |LDFLAGS = -s -all-static|g' frontend/Makefile
make
