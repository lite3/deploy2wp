#!/bin/bash
#
#
# install.sh [dev]
# - dev do not switch branch

set -e

DIR=$(cd `dirname $0`; pwd)

cd $DIR

dev="$1"

if [[ -z $dev ]]; then
    # Get new tags from the remote
    git fetch --tags

    # Get the latest tag name
    latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
     
    # Checkout the latest tag
    git checkout $latestTag

fi


chmod -R +x .
