#!/bin/bash

set -e

echo "this is deply2wp"

# check config for SVN_USERNAME, SVN_PASSWORD, SVN_PLUGIN_URL
checkconfig() {
    errmsg=""
    if [[ -z "$SVN_USERNAME"  ]]; then
        errmsg="please set SVN_USERNAME"
    fi
    if [[ -z "$SVN_PASSWORD" ]]; then
        errmsg="${errmsg}\nplease set SVN_PASSWORD"
    fi
    if [[ -z "$SVN_PLUGIN_URL" ]]; then
        errmsg="${errmsg}\nplease set SVN_PLUGIN_URL"
    fi
    if [[ -n "$errmsg" ]]; then
        echo "$errmsg"
        return 1
    fi
}

checkconfig

# defined constant value
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GIT_DIR="$DIR/../.."
TRUNK_DIR="$GIT_DIR/../../svntmp/trunk"
SVN_AUTHORIZATION="--username $SVN_USERNAME --password $SVN_PASSWORD --no-auth-cache"
SVN="/usr/bin/svn"
SVN_REPOSITORY_URL="$SVN_PLUGIN_URL"

# checkout svn repository to svntmp
$SVN checkout $SVN_REPOSITORY_URL "$TRUNK_DIR/.."

# print branch type: tag or branch
branchtype() {
    for t in `git tag`; do
        if [ "$1"x = "$t"x ]; then
            echo "tag"
            return 0
        fi
    done
    echo "branch"
}

# move current git branch to svn dir
# @param dst
move2svn() {
    cd "$1"
    # delete all files
    $SVN delete ./*
    cp -rf $GIT_DIR .
    rm -rf .git
    rm -rf .travis.yml
    rm -rf .gitmodules
    rm -rf deploy2wp
    # must force add all files
    $SVN add --force .
    cd -
}

deploywptrunk() {
    echo "doing deploywptrunk"
    move2svn "$TRUNK_DIR"
    cd "$TRUNK_DIR"
    $SVN commit $SVN_AUTHORIZATION -m "auto deploy from deplywp" .
    cd -
}

# deply to tag
deploywptag() {
    echo "is tag $TRAVIS_BRANCH"
    deploywptrunk
    $SVN copy $SVN_AUTHORIZATION $SVN_REPOSITORY_URL/trunk $SVN_REPOSITORY_URL/tags/$TRAVIS_BRANCH -m 'auto deploy by deplywp'
}

# deploy to assets
deploywpassets() {
    echo "this is deploywpassets"
    cd "$TRUNK_DIR/../assets"
    $SVN commit $SVN_AUTHORIZATION -m "auto deploy from git" .
}

if [[ "$TRAVIS_BRANCH"x == 'assets'x ]]; then
    deploywpassets
elif [[ "$(branchtype $TRAVIS_BRANCH)"x == 'tag'x ]]; then
    deploywptag
fi

# check current branch is tag
# typename=$(branchtype $TRAVIS_BRANCH)
# echo "$TRAVIS_BRANCH is $typename"
# if [[ "$typename"x == "tag"x ]]; then
#     deploywptag
# elif [[ "$typename"x == "branch"x ]]; then
#         #statements
# fi

# istag '0.1'
# if [[ $? -eq 0 ]]; then
#     echo '0.1 is tag'
# fi

# istag '5'
# if [[ $? -eq 0 ]]; then
#     echo '5 is tag'
# fi
