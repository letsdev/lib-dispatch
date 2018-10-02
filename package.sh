#!/usr/bin/bash

LIBS_HOME=/app/libs

if [ ! -d "${LIBS_HOME}" ]; then
    echo "Missing library folder"    
    exit 1
fi

cd ${LIBS_HOME}/android
zip -r dispatch-${TRAVIS_TAG}-android.zip .
mv *.zip ${LIBS_HOME}

cd ${LIBS_HOME}/linux
zip -r dispatch-${TRAVIS_TAG}-linux.zip .
mv *.zip ${LIBS_HOME}
