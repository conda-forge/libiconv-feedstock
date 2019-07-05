#!/bin/sh

./configure --prefix=${PREFIX}  \
            --host=${HOST}      \
            --build=${BUILD}    \
            --enable-static     \
            --disable-rpath

make -j${CPU_COUNT} ${VERBOSE_AT}
make check
make install

# TODO :: Only provide a static iconv executable for GNU/Linux.
# TODO :: glibc has iconv built-in. I am only providing it here
# TODO :: for legacy packages (and through gritted teeth).
if [[ ${HOST} =~ .*linux.* ]]; then
  chmod 755 ${PREFIX}/lib/libiconv.so.2.6.1
  chmod 755 ${PREFIX}/lib/libcharset.so.1.0.0
fi

# remove libtool files
find $PREFIX -name '*.la' -delete
