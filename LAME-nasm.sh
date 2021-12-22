#!/bin/bash
# LAME MP3 encoder building script
# Author: Guang Yu, ZHANG (Anthony)
# Created: Dec 22, 2021
rm -rf lame
svn checkout https://svn.code.sf.net/p/lame/svn/trunk/lame lame
cd lame
autoreconf -Wnone
# Try to compile i386 assembly for x86-64 target
# For experimental purposes only, FAILED
sed -i 's/CPUTYPE="no"/CPUTYPE="i386"/g' configure
# Win32 requires a leading underscore before function names in compiled object files
# This requirement doesn't exist in Win64, causing a mismatch and linking error
# The following patch solves this problem, but linking still fails because i386 and x86-64
# cannot be mixed. Passing '-f win64' instead of '-f win32' to NASM solves this but
# causes other problems that still fails the linking. The assembly files are designed
# for i386 only, after all.
sed -i 's/	%define _NAMING/;	%define _NAMING/g' libmp3lame/i386/nasm.h
CFLAGS="-O3 -DNDEBUG -ffast-math -flto" \
    ./configure --disable-shared \
                --enable-static \
                --enable-nasm \
                --disable-decoder \
                --disable-rpath \
                --disable-analyzer-hooks
# Makefile uses libtool for linking, so -all-static instead of -static should be specified.
# However above flag cannot be recognized by gcc when 'configure' checks for the compiler
# by attempting to compile a dummy program, and gcc would throw an error, making 'configure'
# believe the compiler is not working.
# Thus, we can't specify LDFLAGS, and should instead perform the following string replacement.
sed -i 's/LDFLAGS =   -static /LDFLAGS = -s -all-static/g' frontend/Makefile
make
