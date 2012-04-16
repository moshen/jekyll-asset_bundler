# Jekyll Asset Bundler

Jekyll Asset Bundler is a Jekyll plugin for... bundling assets.
It is hacked onto... I mean, utilizes deep integration with Jekyll
for a seamless deployment experience.

## Installation

Copy or link `asset_bundler.rb` into your `_plugins` folder 
for your Jekyll project.

If your Jekyll project is in a git repository, you can easily
manage your plugins by utilizing git submodules.

To install this plugin as a git submodule:

    git submodule add git://github.com/moshen/jekyll-asset_bundler.git _plugins/asset_bundler

To update:

    cd _plugins/asset_bundler
    git pull origin master

## Status

Currently only supports absolute asset paths in relation to your
source directory.  For example: `/css/mystyle.css` looks for a file
in `my_source_dir/css/mystyle.css`.

#### Features

* Works with [Octopress](http://octopress.org/)
* Custom commands for bundle compression
* Compressed bundle caching
* Bundling and caching of remote assets
* Dev mode, for easy site development with all assets
* Dev-only asset inclusion

#### TODO

* Relative paths support
* CoffeeScript and LessCSS compilation support
* Google Closure Compiler support

#### Notes

*v0.05* - Changed from using Liquid::Tags to Liquid::Blocks.
This will break on existing bundle markup if you upgrade.

Why change it?  Well, Liquid::Tags have to be on one line,
whereas Liquid::Blocks do not, also it opens up some more
flexibility, as additional options could be included in the
tag text.

#### Is it production ready?

Consider this alpha software, though for small Jekyll sites you
should have no problem using it.

## Usage

Once installed in your `_plugins` folder Jekyll Asset Bundler provides
Liquid::Blocks to use which will generate the appropriate
markup for including JavaScript and CSS.
Each of the following blocks consumes a [YAML](http://yaml.org)
formatted array.

### Liquid::Blocks

#### bundle

    {% bundle %} [/js/main.js, /js/somethingelse.js] {% endbundle %}

Is equal to:

    {% bundle %}
    - /js/main.js
    - /js/somethingelse.js
    {% endbundle %}

Remote assets can also be bundled:

    {% bundle %}
    - http://cdnjs.cloudflare.com/ajax/libs/jquery/1.7.2/jquery.min.js
    - //cdnjs.cloudflare.com/ajax/libs/underscore.js/1.3.1/underscore-min.js
    - https://cdnjs.cloudflare.com/ajax/libs/backbone.js/0.9.2/backbone-min.js
    - /js/my_local_javascript.js
    {% endbundle %}

The `bundle` tag will concatenate the provided scripts and compress them
(if desired), making a hash of the new file to use
as a filename.  The proper markup is inserted to include your bundle file.

#### bundle_glob

    {% bundle_glob %}
    - /js/*.js
    - /css/*.css
    {% endbundle_glob %}

The `bundle_glob` tag uses the
[Ruby Dir.glob](http://ruby-doc.org/core-1.9.3/Dir.html#method-c-glob)
method to include multiple assets.
  WARNING: assets will be included in alphanumeric order,
this may screw something up.

#### dev_assets

    {% dev_assets %}
    - /js/less.js
    {% enddev_assets %}

The `dev_assets` tag includes the normal markup for the referenced
assets only in 'dev mode'.  The array items can either be local files
or urls for external scripts and are included as-is.
At any other time, it does nothing.
In a future version (hopefully soon), this will play a role in
utilizing things like LessCSS and CoffeeScript.

## Configuration

Some behavior can be modified with settings in your `_config.yml`.  The
following represents the default configuration:

    asset_bundler:
      compress:
        js: false
        css: false
      base_path: /bundles/
      remove_bundled: false
      dev: false

Here is a breakdown of each configuration option under the top level
`asset_bundler` key.

### compress:

Compresses nothing by default. Change the `js` and `css` keys to
modify compression behavior.

#### js:

To compress with the yui-compressor gem, use 'yui' here,
to compress with the closure compiler gem, use 'closure' here,
to compress with a custom command, enter it for the
appropriate asset type:

    compress:
      js: yuicompressor -o :outfile :infile

This example will run the yuicompressor command while
substituting :outfile and :infile for temporary files
stored in `_asset_bundler_cache`.

If either :outfile or :infile are omitted, stdout and
stdin will be used.  *WARNING*, stdin and stdout are done
with IO.popen , which doesn't work on Windows

#### css:

Takes the exact same arguments as `js:`, with the exception
of the Google Closure Compiler ( it's JavaScript only ).

### base_path:

Where the bundles will be copied within your destination
folder.

Default: `bundles/`.

### remove_bundled:

If set to true, will remove the files included in your
bundles from the destination folder.

Default: `false`.

### dev:

If set to true, enables dev mode.  When dev mode is active,
no bundles are created and all the referenced files are
included individually without modification.

Dev mode is also automatically enabled when using
`jekyll server` or when a top level configuration key: `dev`
is set to true.

Default: `false`.

## Dependencies

Jekyll Asset Bundler uses the
[yui-compressor](https://github.com/sstephenson/ruby-yui-compressor) or
[closure-compiler](https://github.com/documentcloud/closure-compiler) gems
(when configured) and (obviously) jekyll.

## Author

Colin Kennedy moshen@GitHub

