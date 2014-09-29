#!/bin/bash
set -e

rm -rf target

VERSION=$(cat VERSION)
DISTNAME=spark-hpc_${VERSION}
STAGEDIR=target/${DISTNAME}

echo "Building distrbution: ${DISTNAME} in: ${STAGEDIR}"

mkdir -p ${STAGEDIR} 

#copy files
cp -r bin ${STAGEDIR} 
cp -r cluster ${STAGEDIR}
cp -r conf ${STAGEDIR}
cp LICENSE ${STAGEDIR}
cp docs/README.md ${STAGEDIR}

#compile the examples
(cd examples/src && ./make_dist.sh)

cp -r examples/ ${STAGEDIR}

tar -czf target/${DISTNAME}.tar.gz -C target ${DISTNAME}

