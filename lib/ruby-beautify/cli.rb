require 'optparse'

module RBeautify
  class OptBlob
    def initialize
      @options = {}

      @parser = OptionParser.new do |opts|
        opts.banner = App.banner

        opts.on("-V", "--version", "Print version") { |version| @options[:version] = true}
        opts.on("-p", "--pry", "open a pry shell.") { |pry| @options[:pry] = true}
        if App.plugins.include? 'logging'
          opts.on("-l", "--log-level LEVEL", "Change the log level, default is debug.") { |level| RBeautify::Log.level level }
          opts.on("--log-file FILE", "What file to output to, default is STDOUT") { |file| RBeautify::Log.filename file }
        end
      end
    end

    #TODO figure out a more dynamic way to include the parser and hash table.
    def []=(key, value)
      @options[key] = value
    end

    def [](key)
      @options[key]
    end

    # This will build an on/off option with a default value set to false.
    def bool_on(word, description = "")
      Options[word.to_sym] = false
      @parser.on "-#{word.chars.first}", "--[no]#{word}", description  do |o|
        Options[word.to_sym] == o
      end
    end

    # This is the parser value on lifted up.
    def on(*opts, &block)
      @parser.on(*opts, &block)
    end

    def on_tail(*opts, &block)
      @parser.on(*opts, &block)
    end

    def on_head(*opts, &block)
      @parser.on(*opts, &block)
    end

    def parse!
      @parser.banner = App.banner
      @parser.parse!

      if @options[:version]
        puts App.version
        exit 0
      end

      # we need to mash in our config array.  To do this we want to make config
      # options that don't overwrite cli options.
      if App.plugins.include? 'config'
        Config.each do |k,v|
          @options[k] = v if !@options[k]
        end
      end
    end

    def on_pry
      if @options[:pry]
        require 'pry'
        binding.pry
      end
    end
  end

  App.plugins.push "cli"
  Options = OptBlob.new
end