#!/bin/sh

setEnv() {
    if [ -z $GITHUB_ENV ]; then
        echo $1="$2" >> $GITHUB_ENV
    else
        export $1="$2"
    fi
}
