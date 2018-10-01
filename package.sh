#!/usr/bin/bash

LIBS_HOME=/app/libs

if [ ! -d "${LIBS_HOME}" ]; then
    echo "Missing library folder"    
    exit 1
fi

MVN_VERSION=$(mvn -q \
    -Dexec.executable=echo \
    -Dexec.args='${project.version}' \
    --non-recursive \
    exec:exec)

echo "EXPORT TRAVIS_TAG to ${MVN_VERSION}"
export TRAVIS_TAG=${MVN_VERSION}

cd ${LIBS_HOME}/android
zip -r dispatch-${MVN_VERSION}-android.zip .

cd ${LIBS_HOME}/linux
zip -r dispatch-${MVN_VERSION}-linux.zip .

echo "Add tag ${TRAVIS_TAG}"
git tag "${TRAVIS_TAG}" || true
