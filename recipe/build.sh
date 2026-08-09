#!/usr/bin/env sh

set -euxo pipefail

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./build-aux
cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./libcharset/build-aux

./configure --prefix=${PREFIX}  \
            --host=${HOST}      \
            --build=${BUILD}    \
            --enable-static     \
            --disable-rpath     \
            --enable-extra-encodings

if [[ "${target_platform}" == osx-* ]]; then
    make -f Makefile.devel CC="${CC_FOR_BUILD}" CFLAGS="${CFLAGS}"
fi

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  make check
fi

make install

if [[ ${HOST} =~ .*linux.* ]]; then
  chmod 755 ${PREFIX}/lib/libiconv.so.2.7.0
  chmod 755 ${PREFIX}/lib/libcharset.so.1.0.0
  if [ -f ${PREFIX}/lib/preloadable_libiconv.so ]; then
    chmod 755 ${PREFIX}/lib/preloadable_libiconv.so
  fi
fi

# Remove libtool files.
find $PREFIX -name '*.la' -delete
