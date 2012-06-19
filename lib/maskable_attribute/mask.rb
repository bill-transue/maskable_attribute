module MaskableAttribute
  class Masks
    include Enumerable

    #:bar
    #:foo => :bar
    #:foo => [ :bar, baz, :qux ]
    #:foo => { :format => :two_digit }
    #:foo => { :formats => [ :two_digit, :upcase, :downcase ] }
    #:bar => { :exclusive_format => { :capitalized => Proc.new{ |mask| mask.captialized } } }
    #:bar => { :exclusive_formats => { :capitalized => Proc.new{ |mask| mask.captialized }, :titleized => :titleize } }
    #:baz => { :default_format => :titleize }
    #:bar => [ :quux, { :formats => ... } ]
    #:bar => [ Proc.new { |object| object.size * 3 }, { :formats => ... } ]
    def initialize(masks)
      @masks = masks.map do |mask|
        if mask.is_a? Array
          Mask.new mask.first => mask.last
        else
          Mask.new mask
        end
      end
    end

    def each(&block)
      @masks.each(&block)
      return self
    end

    def [](accessor)
      (find_by_accessor(accessor) || Mask.new).accessor(accessor)
    end

    def find_by_accessor(accessor)
      @masks.find do |mask|
        mask.accessed_by? accessor
      end
    end

    def names
      @masks.map(&:name).map(&:to_sym)
    end
  end

  class Mask
    attr_accessor :accessor, :name, :method, :formats

    def initialize(options=nil)
      if options.is_a? Symbol
        @name = @method = options.to_sym
        options = {}
      elsif options.is_a? Hash
        @name, options = options.flatten
        if options.is_a? Symbol or options.is_a? Proc
          @method = options
          options = {}
        else
          if options.is_a? Array
            @method = options.shift
            options = options.extract_options!
          else
            @method = @name
          end
        end
      end
      @formats = Formatting::Formats.new options
    end

    def name
      @name.to_s.tr "_", " "
    end

    def accessor(*accessed_with)
      if accessed_with.empty?
        @accessor || ""
      else
        @accessor = accessed_with.first
        self
      end
    end

    def unmask(*args)
      object = args.first
      options = args.extract_options!
      format = options[:formatted] || accessor.sub(@name.to_s, "").strip.to_sym

      formats.apply format do
        begin
          if @method.is_a? Proc
            @method.call object
          elsif @method.is_a? Symbol
            object.send(@method) if object.respond_to? @method
          else
            nil
          end
        rescue NoMethodError
          nil
        end
      end
    end

    def accessed_by
      formats.names.map { |format| format.to_s + " " + name}.tap do |accessed_by|
        accessed_by.push name unless formats.are_exclusive?
      end
    end

    def accessed_by?(possible_accessor)
      accessed_by.include? possible_accessor
    end
  end
end
