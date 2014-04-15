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

#### Notes

**v0.05** - Changed from using Liquid::Tags to Liquid::Blocks.
This will break on existing bundle markup if you upgrade.

Why change it?  Well, Liquid::Tags have to be on one line,
whereas Liquid::Blocks do not, also it opens up some more
flexibility, as additional options could be included in the
tag text.

**v0.08** - Changed the `cdn` config parameter to `server_url` in order to be
more generic.  For the time being, `cdn` still works (see below).

Why change it?  There seemed to be a little confusion about the parameter name
and what the parameter does.

**v0.11** - `jekyll --watch` now turns on dev mode.  Removed code for
compatibility with versions of Jekyll pre 1.0.

Why change it?  `jekyll --watch` isn't really supported by the plugin anyway.
Also, Jekyll is changing and I don't want this to be any more of an
unmaintainable mess.

#### Is it production ready?

Consider this beta software, though for small Jekyll sites you
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

Remote assets will be cached in the `_asset_bundler_cache` folder
(in the same directory as your `_plugins` folder). If you want to
regenerate cached items, delete the cache folder.

The `bundle` tag will concatenate the provided scripts and make a hash of
the result.  This hash is used as a filename.  The Bundle is then compressed
(if desired), and the final result cached in the `_asset_bundler_cache` folder.
Therefore, the bundle is only recreated and compressed again if the source
files have been modified.  This greatly speeds up future site builds.

**Note:** Asset Bundler makes no attempt to clean up the cache folder.  If it
has grown too large, simply delete it.

The proper markup is finally inserted to include your bundle file.

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
      server_url:
      remove_bundled: false
      dev: false
      markup_templates:
        js: "<script type='text/javascript' src='{{url}}'></script>\n"
        css: "<link rel='stylesheet' type='text/css' href='{{url}}' />\n"

Here is a breakdown of each configuration option under the top level
`asset_bundler` key.

### compress:

Compresses nothing by default. Change the `js` and `css` keys to
modify compression behavior.

#### js:

To compress with the yui-compressor gem, use 'yui' here,
to compress with the closure compiler gem, use 'closure' here.

    compress:
      js: yui

To compress with a system command, enter it for the
appropriate asset type:

    compress:
      js: yuicompressor -o :outfile :infile

This example will run a yuicompressor command from your PATH 
while substituting :outfile and :infile for temporary files
stored in `_asset_bundler_cache`.

If either :outfile or :infile are omitted, stdout and
stdin will be used.  *WARNING*, stdin and stdout are done
with IO.popen , which doesn't work on Windows

**Note:** Some have reported other issues when using the yui-compressor or
closure compiler gems on Windows. If you having trouble on windows, try
specifying a command as outlined above.

#### css:

Takes the exact same arguments as `js:`, with the exception
of the Google Closure Compiler ( it's JavaScript only ).

### base_path:

Where the bundles will be copied within your destination
folder.

Default: `/bundles/`.

### server_url:

**NOTE:** In v0.07 and earlier this setting was `cdn`.  The `cdn` key still
works and will act as an alias.  However, if the `server_url` key is set, it
will override `cdn`.

The root path of your server\_url or CDN (if you use one).
For example: http://my-cdn.cloudfront.net/

Jekyll Asset Bundler checks to make sure that this setting ends in a slash.

Default: ` ` (blank).

### remove_bundled:

If set to true, will remove the files included in your
bundles from the destination folder.

Default: `false`.

### dev:

**NOTE:** In v0.10 and earlier, dev mode was not enabled automatically for
`--auto` or `--watch` mode.

If set to true, enables dev mode.  When dev mode is active,
no bundles are created and all the referenced files are
included individually without modification.

Dev mode is also automatically enabled when using
`jekyll server`, `jekyll --watch` or when a top level configuration key: `dev`
is set to true.

Default: `false`.

### markup_templates:

Use the relevant markup\_template options to override the default templates
for inserting bundles.  Each option is parsed with `Liquid::Template.parse`
and passed a `url` (String) parameter.

**Note:** if you want newlines to be passed in properly, be sure to quote your
templates in `_config.yml`.

#### js:

The default JavaScript markup is fairly verbose.  If you would like a modern
replacement, try `"<script src='{{url}}'></script>\n"`.

Default: `"<script type='text/javascript' src='{{url}}'></script>\n"`

#### css:

The default CSS is also verbose.  If you would like a modern
replacement, try `"<link rel=stylesheet href='{{url}}'>\n"`.

Default: `"<link rel='stylesheet' type='text/css' href='{{url}}' />\n"`

## Dependencies

Jekyll Asset Bundler uses the
[yui-compressor](https://github.com/sstephenson/ruby-yui-compressor) or
[closure-compiler](https://github.com/documentcloud/closure-compiler) gems
(when configured) and (obviously)
[Jekyll](http://jekyllrb.com).

## Author

Colin Kennedy, moshen on GitHub

## License

[MIT](http://colken.mit-license.org),
see LICENSE file.

