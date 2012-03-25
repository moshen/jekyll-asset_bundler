
require 'yaml'
require 'digest/md5'

module Jekyll

  class BundleTag < Liquid::Tag
    @@supported_types = ['js', 'css']

    def initialize(tag_name, text, tokens)
      super
      @text = text 
      @assets = YAML::load(text)
      @files = {}
    end

    def render(context)
      src = context.registers[:site].config["source"]

      add_files_from_list(src, @assets)

      markup = ""

      @files.each do|k,v|
        markup.concat(Bundle.new(v, k, context).markup())
      end

      markup
    end

    def add_files_from_list(src, list)
      list.each do|a|
        path = File.join(src, a)
        if File.basename(a) !~ /^\.+/ and File.file?(path)
          add_file_by_type(a)
        elsif File.basename(a) !~ /^\.+/ and File.directory?(path)
          dir_list = Dir.entries(path).map{|d| File.join(a, d)}
          add_files_from_list(src, dir_list)
        end
      end
    end

    def add_file_by_type(file)
      if file =~ /\.([^\.]+)$/
        type = $1
        return if @@supported_types.index(type).nil?
        if !@files.key?(type)
          @files[type] = []
        end

        @files[type].push(file)
      end
    end

  end

  class BundleGlobTag < BundleTag
    def add_files_from_list(src, list)
      list.each do|a|
        Dir.glob(File.join(src, a)) do|f|
          if f !~ /^\.+/ and File.file?(f)
            add_file_by_type(f.sub(src,''))
          end
        end
      end
    end

  end

  class DevAssetsTag < BundleTag
    def render(context)
      if Bundle.config(context)['dev']
        super(context)
      else
        ''
      end
    end

    def add_files_from_list(src, list)
      list.each do|a|
        add_file_by_type(a)
      end
    end
  end

  class Bundle
    @@bundles = {}
    @@default_config = {
      'compile'        => { 'coffee' => false, 'less' => false },
      'compress'       => { 'js'     => false, 'css'  => false },
      'base_path'      => '/bundles/',
      'remove_bundled' => false,
      'dev'            => false
    }
    attr_reader :content, :hash, :filename, :base

    def initialize(files, type, context)
      @files    = files
      @type     = type
      @context  = context
      @content  = ''
      @hash     = ''
      @filename = ''

      @config = Bundle.config(@context)
      @base = @config['base_path']

      @filename_hash = Digest::MD5.hexdigest(@files.join())
      if @@bundles.key?(@filename_hash)
        @filename = @@bundles[@filename_hash].filename
        @base     = @@bundles[@filename_hash].base
      else
        load_content()
      end
    end

    def self.config(context)
      if context.registers[:site].config.key?("asset_bundler")
        @@default_config.deep_merge(context.registers[:site].config["asset_bundler"])
      else
        @@default_config
      end
    end

    def load_content()
      if @config['dev']
        @@bundles[@filename_hash] = self
        return
      end

      src = @context.registers[:site].config["source"]

      @files.each do|f|
        @content.concat(File.read(File.join(src, f)))
      end
      
      # TODO: Compilation of Less and CoffeeScript would go here
      compress() if @config['compress'][@type]
      @hash = Digest::MD5.hexdigest(@content)
      @filename = "#{@hash}.#{@type}"

      @context.registers[:site].static_files.push(self)
      remove_bundled() if @config['remove_bundled']

      @@bundles[@filename_hash] = self
    end

    # Removes StaticFiles from the _site if they are bundled
    #   and the remove_bundled option is true
    #   which... it isn't by default
    def remove_bundled()
      src = @context.registers[:site].config['source']
      @files.each do|f|
        @context.registers[:site].static_files.select! do|s|
          if s.class == StaticFile
            s.path != File.join(src, f)
          else
            true
          end
        end
      end
    end

    def compress()
      return if @config['dev']

      case @config['compress'][@type]
        when 'yui'
          compress_yui()
        # TODO: Put call to compress_command here
      end
    end

    def compress_yui()
      require 'yui/compressor'
      case @type
        when 'js'
          c = YUI::JavaScriptCompressor.new
          @content = c.compress(@content)
        when 'css'
          c = YUI::CssCompressor.new
          @content = c.compress(@content)
      end
    end

    def markup()
      return dev_markup() if @config['dev']
      case @type
        when 'js'
          "<script type='text/javascript' src='#{@base}#{@filename}'></script>\n"
        when 'coffee'
          "<script type='text/coffeescript' src='#{@base}#{@filename}'></script>\n"
        when 'css'
          "<link rel='stylesheet' type='text/css' href='#{@base}#{@filename}' />\n"
        when 'less'
          "<link rel='stylesheet/less' type='text/css' href='#{@base}#{@filename}' />\n"
      end
    end

    def dev_markup()
      output = ''
      @files.each do|f|
        case @type
          when 'js'
            output.concat("<script type='text/javascript' src='#{f}'></script>\n")
          when 'coffee'
            output.concat("<script type='text/coffeescript' src='#{f}'></script>\n")
          when 'css'
            output.concat("<link rel='stylesheet' type='text/css' href='#{f}' />\n")
          when 'less'
            output.concat("<link rel='stylesheet/less' type='text/css' href='#{f}' />\n")
        end
      end

      return output
    end

    # Methods required by Jekyll::Site to write out the bundle
    #   This is where we give Jekyll::Bundle a Jekyll::StaticFile
    #   duck call and send it on its way.
    def destination(dest)
      File.join(dest, @base, @filename)
    end

    def write(dest)
      dest_path = destination(dest)
      return false if File.exists?(dest_path)

      FileUtils.mkdir_p(File.dirname(dest_path))
      File.open(dest_path, "w") do|o|
        o.write(@content)
      end

      true
    end
    # End o' the duck call

  end

end

Liquid::Template.register_tag('bundle'     , Jekyll::BundleTag    )
Liquid::Template.register_tag('bundle_glob', Jekyll::BundleGlobTag)
Liquid::Template.register_tag('dev_assets' , Jekyll::DevAssetsTag )

