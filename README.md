# Jekyll Asset Bundler

Jekyll Asset Bundler is a Jekyll plugin for er, bundling assets.
It is hacked onto... I mean, utilizes deep integration with Jekyll
for a seamless deployment experience.

## Installation

Copy or link `asset_bundler.rb` into your `_plugins` folder 
for your Jekyll project.

If your Jekyll project is in a git repository, you can easily
manage your plugins by utilizing git submodules.

To install this plugin:

    git submodule add git://github.com/moshen/jekyll-asset_bundler.git _plugins/asset_bundler

## Status

Currently only supports absolute asset paths in relation to your
source directory.  For example: `/css/mystyle.css` looks for a file
in `my_source_dir/css/mystyle.css`.

Works with [Octopress](http://octopress.org/)

TODO:

* Work in `jekyll server` mode without explicit dev declaration
* Relative paths support
* CoffeeScript and LessCSS compilation support
* Google Closure Compiler support

####Is it production ready?

Consider this alpha software, though for small Jekyll sites you
should have no problem using it.

## Usage

Once installed in your `_plugins` folder Jekyll Asset Bundler provides
Liquid::Tags to use instead of the typical `<script>` and `<ref>` tags
for including JavaScript and CSS.  Each of the following tags takes
a [YAML](http://yaml.org) formatted array as it's sole argument.

### Liquid::Tags

    {% bundle [/js/main.js, /js/somethingelse.js] %}

The `bundle` tag will concatenate the provided scripts and compress them
(if desired), making a hash of the new file to use
as a filename.  The proper markup is inserted to include your bundle file.

    {% bundle_glob [/js/*.js, /css/*.css] %}

The `bundle_glob` tag uses the
[Ruby Dir.glob](http://ruby-doc.org/core-1.9.3/Dir.html#method-c-glob)
method to include multiple assets.
  WARNING: assets will be included in alphanumeric order,
this may screw something up.

    {% dev_assets [/js/less.js] %}

The `dev_assets` tag includes the normal markup for the referenced
assets only in 'dev mode'.  The array items can either be local files
or urls for external scripts.  At any other time, it does nothing.
In a future version (hopefully soon), this will play a role in
utilizing things like LessCSS and CoffeeScript.

## Configuration

Some behavior can be modified with settings in your `_config.yml`.  The
following represents the default configuration:

    asset_bundler:
      # compresses nothing by default
      #   to compress with the yui-compressor gem, use 'yui' here
      compress:
        js: false
        css: false
      base_path: /bundles/

      # bundled files will not be copied into your _site or
      #   alternative destination folder
      remove_bundled: false 

      # enables 'dev mode', no bundles are created and all
      #   referenced files are included individually
      dev: false

## Dependencies

Jekyll Asset Bundler uses the yui-compressor gem (when configured) and (obviously) jekyll.

## Author

Colin Kennedy moshen@GitHub

