#!/bin/sh

cd /tmp
git clone https://github.com/SGpp/SGpp.git && cd SGpp
# git cherry-pick 
patch -p1 -i ${RECIPE_DIR}/osx.patch

if test `uname` = "Darwin"
then
  COMPILER=clang
else
  COMPILER=gnu
fi
export CXXFLAGS="${CXXFLAGS} -std=c++11"

scons COMPILER=${COMPILER} CC=${CC} CXX=${CXX} CFLAGS="${CFLAGS}" CPPFLAGS="${CXXFLAGS} -I${SP_DIR}/numpy/core/include" LINKFLAGS="${LDFLAGS}" BOOST_INCLUDE_PATH=${PREFIX}/include GSL_INCLUDE_PATH=${PREFIX}/include SG_JAVA=0 COMPILE_BOOST_TESTS=0 RUN_PYTHON_TESTS=0 USE_ARMADILLO=0 USE_EIGEN=0 -j${CPU_COUNT} PREFIX=${PREFIX} -Q install || cat config.log
mv ${PREFIX}/lib/sgpp/* ${PREFIX}/lib
cp -RLv lib/pysgpp ${SP_DIR}

if test `uname` = "Darwin"
then
  for mod in datadriven combigrid optimization pde solver quadrature base
  do
    install_name_tool -change ${mod}/libsgpp${mod}.dylib @rpath/libsgpp${mod}.dylib ${SP_DIR}/pysgpp/_pysgpp_swig.so
    install_name_tool -change ${mod}/libsgpp${mod}.dylib @rpath/libsgpp${mod}.dylib ${PREFIX}/lib/libsgppdatadriven.dylib
    install_name_tool -change ${mod}/libsgpp${mod}.dylib @rpath/libsgpp${mod}.dylib ${PREFIX}/lib/libsgppcombigrid.dylib
    install_name_tool -change ${mod}/libsgpp${mod}.dylib @rpath/libsgpp${mod}.dylib ${PREFIX}/lib/libsgppdatadriven.dylib
    install_name_tool -change ${mod}/libsgpp${mod}.dylib @rpath/libsgpp${mod}.dylib ${PREFIX}/lib/libsgppoptimization.dylib
    install_name_tool -change ${mod}/libsgpp${mod}.dylib @rpath/libsgpp${mod}.dylib ${PREFIX}/lib/libsgpppde.dylib
    install_name_tool -change ${mod}/libsgpp${mod}.dylib @rpath/libsgpp${mod}.dylib ${PREFIX}/lib/libsgppsolver.dylib
    install_name_tool -change ${mod}/libsgpp${mod}.dylib @rpath/libsgpp${mod}.dylib ${PREFIX}/lib/libsgppquadrature.dylib
    install_name_tool -change ${mod}/libsgpp${mod}.dylib @rpath/libsgpp${mod}.dylib ${PREFIX}/lib/libsgppbase.dylib
  done
fi

python ./base/examples/quadrature.py
python ./optimization/examples/optimization.py
