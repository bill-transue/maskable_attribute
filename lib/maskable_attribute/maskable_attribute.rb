module MaskableAttribute
  class MaskableAttribute
    attr_accessor :object, :attribute, :masks

    def initialize(object, attribute, masks)
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
        value.scan(/(?<={)\w+(?=})/).each do |mask| #mask: two_digit model_series
          value = value.sub "{#{mask}}", @masks[mask].unmask(@object) unless @masks[mask].unmask(@object).nil?
        end
      end
      value
    end

    alias :to_s :masked

    def masked_object
      @object
    end

    def unmasked
      @object.read_attribute attribute
    end

    def set(value)
      unless value.blank?
        @masks.each do |mask|
          mask.accessed_by.each do |mask_accessor|
            value.sub! /#{mask.unmask(@object, :formatted => mask_accessor)}(?![^{]*})/, "{#{mask_accessor}}" unless mask.unmask(@object).blank?
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
