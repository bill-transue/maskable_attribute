module MaskableAttribute
  class MaskableAttribute
    attr_accessor :object, :attribute, :masks

    def initialize(object, attribute, masks)
      @object = object
      @attribute = attribute
      @masks = masks
    end

    def masks
      @masks
    end

    def masked
      value = unmasked
      if !value.blank? and value.match(/\{.*\}/)
        value.scan(/(?<={)\w+(?=})/).each do |mask|
          value.sub! "{#{mask}}", get_value_of(mask)
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
      masks.each do |mask|
        value.sub! /#{get_value_of(mask)}(?![^{]*})/, "{#{mask}}" unless get_value_of(mask).blank?
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

    private
    def get_value_of(mask)
      two_digits = !!mask.to_s.sub!("two_digits_", "")
      if @object.respond_to? mask
        if two_digits
          format '%02d', @object.send(mask)
        else
          @object.send mask
        end
      else
        raise InvalidMask.new mask, @object
      end
    end
  end
end
