module MaskableAttribute
  module Formatting
    class Formats < Hash

      #{ :format => :two_digit }
      #{ :formats => [ :upcase, :downcase ] }
      #{ :exclusive_format => { :capitalized => Proc.new{ |mask| mask.captialized } } }
      #{ :exclusive_formats =>{ :capitalized => Proc.new{ |mask| mask.captialized }, :titleized => :titleize } }
      #{ :default_format => :titleize }
      attr_accessor :are_exclusive, :has_default, :default
      def initialize(options = {})
        @are_exclusive, @has_default = false, false
        @default = nil
        unless options.nil?
          options.each do |type, formats|
            if formats.is_a? Symbol or formats.is_a? Proc
              self[formats] = Format.new formats
            elsif formats.is_a? Array
              formats.each do |format|
                self[format] = Format.new format
              end
            else
              formats.each do |format, method|
                self[format] = Format.new method || format
              end
            end

            if type.to_s.include? "exclusive"
              @are_exclusive = true
            elsif type.to_s.include? "default"
              @has_default = true
              @default = self[formats]
            end
          end
        end
      end

      def apply(format, &block)
        fetch(format, (has_default? ? @default : Format.new)).apply yield unless yield.nil?
      end

      def names
        keys
      end

      def are_exclusive?
        @are_exclusive
      end

      def has_default?
        @has_default
      end
    end

    class Format
      def initialize(method=nil)
        @method = method
      end

      def apply(input)
        if @method.is_a? Symbol
          input.send(@method)
        elsif @method.is_a? Proc
          @method.call input
        else
          input
        end
      end
    end
  end
end
