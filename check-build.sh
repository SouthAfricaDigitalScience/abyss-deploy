#!/bin/bash -e
. /etc/profile.d/modules.sh
module load ci
module add boost/1.59.0-gcc-${GCC_VERSION}-mpi-1.8.8
module add sparsehash
module add sqlite

cd ${WORKSPACE}/${NAME}-${VERSION}/build-${BUILD_NUMBER}
make check

echo $?

make install
mkdir -p ${REPO_DIR}
mkdir -p modules
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

module-whatis   "$NAME $VERSION."
setenv       ABYSS_VERSION       $VERSION
setenv       ABYSS_DIR           /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$::env(NAME)/$::(VERSION)/$::env(VERSION)-mpi-$::env(OPENMPI_VERSION)-gcc-$::env(GCC_VERSION)
prepend-path LD_LIBRARY_PATH   $::env(ABYSS_DIR)/lib
prepend-path GCC_INCLUDE_DIR   $::env(ABYSS_DIR)/include
prepend-path CFLAGS            "-I$::env(ABYSS_DIR)/include"
prepend-path LDFLAGS           "-L$::env(ABYSS_DIR)/lib"
prepend-path PATH              $::env(ABYSS_DIR)/bin
MODULE_FILE
) > modules/$VERSION

mkdir -p ${BIOINFORMATICS_MODULES}/${NAME}
cp modules/$VERSION ${BIOINFORMATICS_MODULES}/${NAME}
echo "checking the module"
module add ${NAME}/${VERSION}
echo "checking whether paths are correct"
which ABYSS
echo "Checking executable"
ABYSS --help
