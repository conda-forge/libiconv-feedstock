#!/usr/bin/env sh

set -euxo pipefail

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./build-aux
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./libcharset/build-aux

# refresh the flags
if [[ "${target_platform}" == osx-* ]]; then
    mv lib/flags.h lib/flags.h.bak
    ${CC} ${CFLAGS} lib/genflags.c -o genflags
    ./genflags > lib/flags.h
    rm -f genflags
    # Debugging: Show generated diff
    diff -u lib/flags.h.bak lib/flags.h || true
    # Check that UTF-8.MAC is included
    grep utf8mac lib/flags.h
fi

./configure --prefix=${PREFIX}  \
            --host=${HOST}      \
            --build=${BUILD}    \
            --enable-static     \
            --disable-rpath

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  make check
fi
