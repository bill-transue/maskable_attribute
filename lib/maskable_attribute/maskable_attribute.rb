module MaskableAttribute
  class MaskableAttribute
    attr_accessor :object, :value, :masks

    def initialize(object, *masks)
      @object = object
      @masks = masks
    end

    def masks
      @masks
    end

    def masked
      if !@value.blank? and @value.match(/\{.*\}/)
        @value.scan(/(?<={)\w+(?=})/).each do |mask|
          two_digits = !!@value.sub!("two_digits_", "")
          if respond_to? object.mask
            if two_digits
              @value.sub! "{two_digits_#{mask}}", format('%02d', object.send(mask))
            else
              @value.sub! "{#{mask}}", object.send(mask)
            end
          else
            raise InvalidMask.new mask, object
          end
        end
      end
    end

    def masked_object
      object
    end

    def unmasked
      @value
    end
  end
end
