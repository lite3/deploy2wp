#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR
chmod -R +x .

# Get new tags from the remote
git fetch --tags

# Get the latest tag name
latestTag=$(git describe --tags `git rev-list --tags --max-count=1`)
 
# Checkout the latest tag
git checkout $latestTag
