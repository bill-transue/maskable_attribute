module MaskableAttribute
  class MaskableAttribute
    attr_accessor :object, :attribute, :masks

    def initialize(object, attribute, *masks)
      @object = object
      @attribute = attribute
      @masks = masks
    end

    def masks
      @masks
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

    def masked
      value = unmasked
      if !value.blank? and value.match(/\{.*\}/)
        value.scan(/(?<={)\w+(?=})/).each do |mask|
          two_digits = !!value.sub!("two_digits_", "")
          if object.respond_to? mask
            if two_digits
              value.sub! "{two_digits_#{mask}}", format('%02d', object.send(mask))
            else
              value.sub! "{#{mask}}", object.send(mask)
            end
          else
            raise InvalidMask.new mask, object
          end
        end
      end
      value
    end

    alias :to_s :masked

    def masked_object
      object
    end

    def unmasked
      object.read_attribute attribute
    end

    def set(value)
      #TODO Make this method try and determine masks
      value
    end
  end
end
