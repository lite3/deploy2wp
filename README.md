deploy2wp
=========

Automatically deploy your plugin or theme to WordPress.

Github is so popular. Now, use this tool, you can write plugins or themes of wordpress on github, and automatically deployed to wordpress.

How to use?
-----------

**1. import your wordpress repository to Github**

[GitHub Importer](https://import.github.com/new) will help you import your svn repository to Github


**2. add .yml file**

copy blow code in `.travis.yml` file, and put your github repository root dictionary.
~~~ yml
language: php
os:
  - linux

# deploy master to svn truck
# env: DEPLOYMASTER=1

before_script:
  - git clone -b 1.1 https://github.com/lite3/deploy2wp.git 
  - chmod -R +x deploy2wp/scripts
  - deploy2wp/scripts/wp2md.sh README.md readme.txt to-wp

script:
  - deploy2wp/scripts/deploy2wp.sh
  - cat readme.txt
~~~


**3. activity travis-ci service**

1. sign up [Travis-ci](https://travis-ci.org/profile)
2. access [Travis Profile](https://travis-ci.org/profile)
3. click **Sync** button to synchronous your repositories
3. find your repositories and activit it.


**4. set Environment Variables**

1. access https://travis-ci.org/$own/$repository/settings,
   please change $own to your github user name and $repository to your repository name.
2. add SVN_USERNAME, SVN_PASSWORD, SVN_URL to Environment Variables
   - SVN_USERNAME: username of wordpress.org
   - SVN_PASSWORD: password of wordpress.org
   - SVN_URL: wordpress plugins url, etc http://plugins.svn.wordpress.org/wp-resources-url-optimization 


How to remove old submodule?
-----------

~~~
git submodule deinit deploy2wp
git rm --cached deploy2wp
rm -rf .git/modules/deploy2wp
~~~
