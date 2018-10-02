#!/usr/bin/bash

LIBS_HOME=/home/build/app/libs
TARGET_DIR=/home/build/app/dist

if [ ! -d "${LIBS_HOME}" ]; then
    echo "Missing library folder"    
    exit 1
fi

cd ${LIBS_HOME}/android
zip -r dispatch-${TRAVIS_TAG}-android.zip .
mv *.zip ${TARGET_DIR}

cd ${LIBS_HOME}/linux
zip -r dispatch-${TRAVIS_TAG}-linux.zip .
mv *.zip ${TARGET_DIR}
