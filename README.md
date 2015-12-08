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

script: chmod +x deploy2wp/scripts/deploy2wp.sh && deploy2wp/scripts/deploy2wp.sh
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
   - SVN_URL: wordpress plugins url, etc <http://plugins.svn.wordpress.org/wp-resources-url-optimization> 


**5. add deploy2wp to submodle**

1. open command line tool
2. cd to your repository root dictionary
3. execute `git add .travis.yml`
4. execute `git submodule add https://github.com/lite3/deploy2wp.git`
5. execute `git commit -m 'add submodule deploy2wp' && git push origin master`
