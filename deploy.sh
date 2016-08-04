#!/bin/bash -e
# this should be run after check-build finishes.
. /etc/profile.d/modules.sh
echo ${SOFT_DIR}
module add deploy
module add boost/1.59.0-gcc-${GCC_VERSION}-mpi-1.8.8
module add sparsehash
module add sqlite

echo ${SOFT_DIR}
cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
echo "All tests have passed, will now build into ${SOFT_DIR}"
rm -rf *
CFLAGS="-m64" ../configure \
--prefix=${SOFT_DIR}/${VERSION}-mpi-${OPENMPI_VERSION}-gcc-${GCC_VERSION} \
--with-boost=${BOOST_DIR} \
--with-mpi=${OPENMPI_DIR} \
--with-sqlite=${SQLITE_DIR} \
--with-sparsehash=${SPARSEHASH_DIR}
make install -j2
echo "Creating the modules file directory ${LIBRARIES_MODULES}"
mkdir -p ${BIOINFORMATICS_MODULES}/${NAME}
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
    puts stderr "       This module does nothing but alert the user"
    puts stderr "       that the [module-info name] module is not available"
}
module add boost/1.59.0-gcc-${GCC_VERSION}-mpi-1.8.8
module add sparsehash
module add sqlite

module-whatis   "$NAME $VERSION : See https://github.com/SouthAfricaDigitalScience/abyss-deploy"
setenv ABYSS_VERSION       $VERSION
setenv ABYSS_DIR           $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION-mpi-$::env(OPENMPI_VERSION)-gcc-$::env(GCC_VERSION)
prepend-path LD_LIBRARY_PATH   $::env(ABYSS_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(ABYSS_DIR)/include
prepend-path CFLAGS            "-I$::env(ABYSS_DIR)/include"
prepend-path LDFLAGS           "-L$::env(ABYSS_DIR)/lib"
prepend-path PATH              $::env(ABYSS_DIR)/bin
MODULE_FILE
) > ${BIOINFORMATICS_MODULES}/${NAME}/${VERSION}

module add ${NAME}/${VERSION}

which ABYSS
ABYSS --help
