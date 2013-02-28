module MaskableAttribute
  class MaskableAttribute
    attr_accessor :object, :attribute, :masks

    def initialize(object, attribute, masks, options)
      @object = object
      @attribute = attribute
      @masks = Masks.new masks
    end

    def masks
      @masks.names
    end

    def masked
      value = unmasked
      if !value.blank? and value.match(/\{.*\}/)
        value.scan(/(?<={)[^}]+(?=})/).each do |mask| #mask: two_digit model_series
          mask_value = @masks[mask].unmask(@object)
          value = value.sub "{#{mask}}", mask_value.to_s unless mask_value.nil?
        end
      end
      value
    end

    # update an attribute to replace all masks in place
    # i.e. "something{some_mask}cool" will become "somethingelsecool"
    def demask
      @object.send :write_attribute, attribute, masked
    end

    alias :to_s :masked

    def unmasked
      @object.read_attribute attribute
    end

    def set(value)
      unless value.blank?
        @masks.each do |mask|
          mask.accessed_by.each do |mask_accessor|
            value.sub! /#{"(?<!#{@protected_prefixes})" unless @protected_prefixes.blank?}#{mask.unmask(@object, :formatted => mask_accessor)}(?![^{]*})/, "{#{mask_accessor}}" unless mask.unmask(@object).blank?
          end
        end
      end

      value
    end

    class InvalidMask < RuntimeError
      attr :mask, :obj
      def initialize(mask, obj)
        @mask = mask
        @obj = obj
      end

      def to_s
        "Invalid mask '#{@mask}' for #{@obj.class.name}"
      end
    end
  end
end
