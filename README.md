# Heroku Clone

Will clone a Heroku app to a new app. Will clone the following:

  * Code
  * Addons
  * Config Vars (opt-in)
  * Collaborators

## Installation

    $ heroku plugins:install git://github.com/mhubby/heroku-clone.git

## Usage

    $ heroku help clone
    Usage: heroku clone [--from APP_NAME1] --to APP_NAME2 [--with-config]

     clone a Heroku app, along with addons, config, etc.

     -f, --from APP  # source (existing) App
     -t, --to APP    # destination (to-be-created) App

     --with-config   # also copies config keys (use with caution)

     --from may be omitted if current directory is a Heroku repository
     You may only clone an app you have access to.


    $ heroku clone -f example-app -t heroku-banzai-1337

    Cloning example-app to heroku-banzai-1337
      * creating application heroku-banzai-1337
        * new app: heroku-banzai-1337
      * cloning addons
        * [SKIP] logging:basic already installed
        * [INST] mongolab:starter...
      * cloning repository
        * [ BY ] foobar@example.com
        * [FROM] git@heroku.com:example-app.git
        * [INTO] c:/Sites/heroku-banzai-1337
    Cloning into 'c:/Sites/heroku-banzai-1337'...

    -----> Heroku receiving push
    -----> Ruby/Rack app detected
    -----> Installing dependencies using Bundler version 1.1.rc.7
           Running: bundle install --without development:test --path vendor/bundle --binstubs bin/
           Fetching gem metadata from http://rubygems.org/........
           Fetching gem metadata from http://rubygems.org/..
           Installing i18n (0.6.0)
           Installing multi_json (1.1.0)
           Installing activesupport (3.2.2)
           Installing builder (3.0.0)
           Installing activemodel (3.2.2)
           Installing bson (1.6.0)
           Installing bson_ext (1.6.0) with native extensions
           Installing daemons (1.1.8)
           Installing eventmachine (0.12.10) with native extensions
           Installing mongo (1.6.0)
           Installing tzinfo (0.3.31)
           Installing mongoid (2.4.5)
           Installing rack (1.4.1)
           Installing rack-protection (1.2.0)
           Installing tilt (1.3.3)
           Installing sinatra (1.3.2)
           Installing thin (1.3.1) with native extensions
           Using bundler (1.1.rc.7)
           ?[32mYour bundle is complete! It was installed into ./vendor/bundle?[0m
           Cleaning up the bundler cache.
    -----> Discovering process types
           Procfile declares types     -> web
           Default types for Ruby/Rack -> console, rake
    -----> Compiled slug size is 6.3MB
    -----> Launching... done, v4
           http://heroku-banzai-1337.herokuapp.com deployed to Heroku

    To git@heroku.com:heroku-banzai-1337.git
     * [new branch]      master -> master
      * cloning collaborators
        * adding david@heroku.com
    Done.

## Credits

  Branched off **git://github.com/ddollar/heroku-clone.git 4ad050558f7f8d1d199cf2e0e5ef6e51de207e93** by David Dollar
