# encoding: utf-8

###
#  based on github.com/timjansen/hanson
#   Thanks to Tim Jansen


module HANSON


  BACKTICK_ML_QUOTE = Jasony::BACKTICK_ML_QUOTE
  SINGLE_QUOTE      = Jasony::SINGLE_QUOTE
  DOUBLE_QUOTE      = Jasony::DOUBLE_QUOTE

  CLANG_ML_COMMENT  = Jasony::CLANG_ML_COMMENT
  CLANG_COMMENT     = Jasony::CLANG_COMMENT

  KEYWORDS          = Jasony::KEYWORDS
  IDENTIFIER        = Jasony::IDENTIFIER
  TRAILING_COMMA    = Jasony::TRAILING_COMMA

  UNESCAPE_MAP      = Jasony::UNESCAPE_MAP
  ML_ESCAPE_MAP     = Jasony::ML_ESCAPE_MAP



  def self.strip_comments( text )   ## pass 1
    text.gsub( /#{BACKTICK_ML_QUOTE}|#{SINGLE_QUOTE}|#{DOUBLE_QUOTE}|#{CLANG_ML_COMMENT}|#{CLANG_COMMENT}/ox ) do |match|
       ## puts "match: >>#{match}<< : #{match.class.name}"
       if match[0] == ?/    ## comments start with // or /*
         ## puts "!!! removing comments"
         ''    ## remove / strip comments
       else
         match
       end
     end
  end


  def self.normalize_quotes( text )  ## pass 2
     text.gsub( /#{BACKTICK_ML_QUOTE}|#{SINGLE_QUOTE}|#{DOUBLE_QUOTE}/ox ) do |match|
       ## puts "match: >>#{match}<< : #{match.class.name}"

       m = Regexp.last_match
       if m[:backtick_ml_quote]
         ## puts "!!! ml_quote -- convert to double quotes"
         str = m[:backtick_ml_quote]
         str = str.gsub( /\\./ ) {|r| UNESCAPE_MAP[r] || r }
         str = str.gsub( /[\n\r\t"]/ ) { |r| ML_ESCAPE_MAP[r] }
         '"' + str + '"'
       elsif m[:single_quote]
         ## puts "!!! single_quote -- convert to double quotes"
         str = m[:single_quote]
         str = str.gsub( /\\./ ) {|r| UNESCAPE_MAP[r] || r }
         str = str.gsub( /"/, %{\\"} )
         '"' + str + '"'
       else
         match
       end
    end
  end


  def self.convert( text )

    # text is the HanSON string to convert.

    # todo: add keep_line_numbers options - why? why not?
    #  see github.com/timjansen/hanson

    ## pass 1: remove/strip comments
    text = strip_comments( text )

    ## pass 2: requote/normalize quotes
    text = normalize_quotes( text )

    ## pass 3: quote unquoted and remove trailing commas
    text = text.gsub( /#{KEYWORDS}|#{IDENTIFIER}|#{DOUBLE_QUOTE}|#{TRAILING_COMMA}/ox ) do |match|
       ## puts "match: >>#{match}<< : #{match.class.name}"

       m = Regexp.last_match
       if m[:identifier]
         ## puts "!!! identfier -- wrap in double quotes"
         '"' + m[:identifier] + '"'
       elsif m[:trailing_comma]
         ## puts "!!! trailing comma -- remove"
         ''
       else
         match
       end
    end

    text
  end


  def self.parse( text )
    JSON.parse( self.convert( text ) )
  end

end # module HANSON