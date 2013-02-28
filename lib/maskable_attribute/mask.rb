module MaskableAttribute
  class Masks
    include Enumerable

    #:bar
    #:foo => :bar
    #:foo => Proc.new { |object| object.size * 3 }
    #:foo => { :format => :two_digit }
    #:foo => { :formats => [ :two_digit, :upcase, :downcase ] }
    #:bar => { :exclusive_format => { :capitalized => Proc.new{ |mask| mask.captialized } } }
    #:bar => { :exclusive_formats => { :capitalized => Proc.new{ |mask| mask.captialized }, :titleized => :titleize } }
    #:baz => { :default_format => :titleize }
    #:bar => { :method => :quux, { :formats => ... } }
    #:bar => { :method => Proc.new { |object| object.size * 3 }, :formats => ... }
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
      accessor = accessor.tr " ", "_"
      (find_by_accessor(accessor) || Mask.new).accessor(accessor)
    end

    def find_by_accessor(accessor)
      accessor = accessor.tr " ", "_"
      @masks.find do |mask|
        mask.accessed_by? accessor
      end
    end

    def names
      @masks.map(&:name).map(&:to_sym)
    end

    def formatted_names
      @masks.inject([]) do |names, mask|
        names.push mask.name.to_sym
        mask.formats.each do |format, proc|
          names.push "#{format}_#{mask.name}".to_sym
        end
        names
      end
    end
  end

  class Mask
    attr_accessor :accessor, :name, :method, :formats

    def initialize(options=nil)
      if options.is_a? Symbol
        self.name = (@method = options.to_sym)
        options = {}
      elsif options.is_a? Hash
        self.name = options.flatten.first
        options = options.flatten.last
        if options.is_a? Symbol or options.is_a? Proc
          @method = options
          options = {}
        else
          if options.is_a? Hash
            @method = options.delete(:method) || name.to_sym
          elsif options.is_a? Array
            @method = options.shift
            options = options.extract_options!
          else
            @method = name.to_sym
          end
        end
      end
      @formats = Formatting::Formats.new options
    end

    def name=(value)
      @name = value.to_s.tr(' ', '_')
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
      format = (options[:formatted] || accessor).to_s.sub("_" + name.to_s, "").strip.to_sym

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
      formats.names.map { |format| format.to_s + "_" + name}.tap do |accessed_by|
        accessed_by.push name unless formats.are_exclusive?
      end
    end

    def accessed_by?(possible_accessor)
      accessed_by.include? possible_accessor
    end
  end
end
