#!/bin/bash

set -e

echo "this is deploy2wp:https://github.com/lite3/deploy2wp"

COMMIT_MSG="auto deploy from deploy2wp:https://github.com/lite3/deploy2wp"

# defined constant value
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GIT_DIR="$DIR/../.."
SVN_DIR="$GIT_DIR/../../svntmp"/trunk
SVN_AUTHORIZATION="--username $SVN_USERNAME --password $SVN_PASSWORD --no-auth-cache"
SVN="/usr/bin/svn"

IS_PLUGIN=0
IS_THEME=0


# check config for SVN_USERNAME, SVN_PASSWORD, SVN_URL
checkconfig() {
    errmsg=""
    if [[ -z "$SVN_USERNAME"  ]]; then
        errmsg="please set SVN_USERNAME"
    fi
    if [[ -z "$SVN_PASSWORD" ]]; then
        errmsg="${errmsg}\nplease set SVN_PASSWORD"
    fi
    if [[ -z "$SVN_URL" ]]; then
        errmsg="${errmsg}\nplease set SVN_URL"
    fi
    if [[ -n "$errmsg" ]]; then
        echo "$errmsg"
        return 1
    fi
}

initWPType() {
    # remove .svn.wordpress.org and follow char
    wpType=${SVN_URL/.svn.wordpress.org*/}
    # remove http://
    wpType=${wpType/*\/}
    if [[ "$wpType"x == 'plugins'x ]]; then
        IS_PLUGIN=1
    elif [[ "$wpType"x == 'themes'x ]]; then
        IS_THEME=1
    fi
}

# init environment constant
initEnvironment() {
    checkconfig
    initWPType
    
}

initEnvironment



# checkout svn repository to svntmp
$SVN checkout $SVN_URL $SVN_DIR

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
    echo "move2svn $1"
    ls -lha .
    $SVN delete ./*
    cp -rf $GIT_DIR/ .
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
    move2svn "$SVN_DIR/trunk"
    cd "$SVN_DIR/trunk"
    $SVN commit $SVN_AUTHORIZATION -m "$COMMIT_MSG" .
    cd -
}

# deply to tag
deploywptag() {
    echo "is tag $TRAVIS_BRANCH"
    deploywptrunk
    $SVN copy $SVN_AUTHORIZATION $SVN_URL/trunk $SVN_URL/tags/$TRAVIS_BRANCH -m "$COMMIT_MSG"
}

# deploy to assets
deploywpassets() {
    echo "this is deploywpassets"
    move2svn $SVN_DIR/assets
    cd "$SVN_DIR/assets"
    $SVN commit $SVN_AUTHORIZATION -m "$COMMIT_MSG" .
}

if [[ "$TRAVIS_BRANCH"x == "assets"x ]]; then
    deploywpassets
elif [[ "$(branchtype $TRAVIS_BRANCH)"x == "tag"x ]]; then
    deploywptag
elif [[ "$TRAVIS_BRANCH"x == "master"x ]]; then
    if [[ -n "$DEPLOYMASTER" ]]; then
        deploywptrunk
    fi
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
