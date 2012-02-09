#!/usr/bin/env ruby

LINE_ENDING = ENV['CODA_LINE_ENDING']

class CodaCssParser
  
  class Declaration
    attr_reader :property
    attr_reader :values
    
    def initialize(code)
      @property = nil
      @values = nil
      
      m = code.match(/([^:]+):(.*)/im)
      @property = m[1].strip
      @values = m[2].strip

      @values.chop! if @values.match(/[;]$/im)
    end
    
    def to_s
      "#{@property}: #{@values};"
    end
    
    def to_a
      [@property, @values]
    end
  end
  
  class Rule
    attr_reader :code
    attr_reader :selectors
    attr_reader :declarations
    
    def initialize(code)
      @code = code
      @selectors = []
      @declarations = []
      
      m = code.match(/(^[\ ]*[a-z\.\#][^\{]*)[^\{]*\{([^\}]*)/im)
      @selectors = m[1].split(',').collect{|a| a.strip}
      
      m[2].strip.scan(/[^:]+:(?:[^;]+)[;]?/im).each do |rule|
        @declarations.push CodaCssParser::Declaration.new(rule)
      end
    end
		
    def to_s
      if !self.is_fancy?
        beginning = ::LINE_ENDING + "{" + ::LINE_ENDING + "    "
        join_str = ::LINE_ENDING + "    "
        ending = ::LINE_ENDING + "}" + ::LINE_ENDING
      else
        beginning = " { "
        join_str = " "
        ending = " }" + ::LINE_ENDING
      end
      
      @selectors.join(', ') + beginning + @declarations.each.to_a.join(join_str) + ending
    end
    
    def to_a
      [@selectors, @declarations, @code]
    end
		
    def is_fancy?
      @code.lines.to_a.size > 1 && @code.lines.to_a[1].match(/^[\{]/i)
    end
  end

  attr_reader :rules

  def self.formatted_output(code)
    css = CodaCssParser.new(code)
    if css.rules.empty?
      print code #No CSS selected
    else
      css.rules.each do |block|
				print block.to_s
      end
    end
  end
  
  def initialize(code)
    @rules = []
    @code = code.strip
    style_blocks = @code.scan(/^[\ ]*[a-z\.\#][^\{]*?[^\{]*?\{[^\}]*?\}/im)
    style_blocks.each do |style_block|
      @rules << CodaCssParser::Rule.new(style_block)
    end
  end

end

CodaCssParser.formatted_output(ENV['CODA_SELECTED_TEXT'])
