#!/bin/bash

set -e

echo "this is deploy2wp:https://github.com/litefeel/deploy2wp"

COMMIT_MSG="auto deploy from deploy2wp:https://github.com/litefeel/deploy2wp"

# defined constant value
TOOLS_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
GIT_DIR=$( cd "$TOOLS_DIR/../.." && pwd)
SLUG=$( basename "$GIT_DIR" )
SVN_DIR="/tmp/$SLUG"
SVN_AUTHORIZATION="--username $SVN_USERNAME --password $SVN_PASSWORD --no-auth-cache"


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
    orgindir=$( pwd )
    cd "$1"
    # delete all files
    echo "move2svn $1"
    ls -lha .
    # clean svn repo
    echo -n "Cleaning local copy of SVN repo..."
    for file in $(find . -type f -and -not -path "*.svn/*")
    do
        rm $file
    done
    find . -type d -and -not -path "*.svn/*" -empty -delete
    echo "Done."

    # copy current plugin to svn dir
    echo -n "Copying git files to SVN repo..."
    cd $GIT_DIR
    git checkout-index --quiet --all --force --prefix=$1/
    echo "Done."

    cd "$1"

    # install npm, bower, and composer dependencies
    if [ -f composer.json ]; then
        echo -n "Installing dependencies..."
        composer install --quiet --no-dev --optimize-autoloader &>/dev/null
        echo "Done."
    fi

    # transform the readme
    if [ -f README.md ]; then
        echo -n "Converting the README to WordPress format..."
        $TOOLS_DIR/wp2md.sh README.md readme.txt to-wp
        echo "Done."
        echo 'Show readme.txt\n-----------------'
        cat readme.txt
    fi

    # remove unneeded files via .svnignore
    echo -n "Removing unwanted development files using .svnignore..."
    for file in $(cat ".svnignore" 2> /dev/null)
    do
        rm -rf ./$file
    done
    echo "Done."

    echo "svn stat"
    svn stat
    # svn addremove
    echo "Adding new commit to SVN..."
    svn stat | awk '/^\?/ {system("svn add --force "$2)}'
    svn stat | awk '/^\M/ {system("svn add --force "$2)}'
    svn stat | awk '/^\!/ {system("svn rm  --force "$2)}'

    cd $orgindir
}

deploywptrunk() {
    echo "doing deploywptrunk"
    move2svn "$SVN_DIR/trunk"
    cd "$SVN_DIR/trunk"
    echo "------ svn stat ---------"
    svn stat
    svn commit $SVN_AUTHORIZATION -m "$COMMIT_MSG" .
    cd -
}

# deply to tag
deploywptag() {
    echo "is tag $TRAVIS_BRANCH"
    echo "check tag: $SVN_DIR/tags/$TRAVIS_BRANCH"
    if [[ -d $SVN_DIR/tags/$TRAVIS_BRANCH ]]; then
        echo "Path '$SVN_DIR/tags/$TRAVIS_BRANCH' already exists"
        exit 1
    fi
    deploywptrunk
    svn copy $SVN_AUTHORIZATION $SVN_URL/trunk $SVN_URL/tags/$TRAVIS_BRANCH -m "$COMMIT_MSG"
}

# deploy to assets
deploywpassets() {
    echo "this is deploywpassets"
    move2svn $SVN_DIR/assets
    cd "$SVN_DIR/assets"
    svn commit $SVN_AUTHORIZATION -m "$COMMIT_MSG" .
}


initEnvironment

# checkout svn repository to svntmp
svn checkout $SVN_URL $SVN_DIR


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
