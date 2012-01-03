module MaskableAttribute
  class MaskableAttribute
    attr_accessor :value, :masks

    def initialize(*masks)
      @masks = masks
    end

    def available_masks
      @masks
    end

    def masked(obj)
      if !@value.blank? and @value.match(/\{.*\}/)
        @value.scan(/(?<={)\w+(?=})/).each do |mask|
          two_digits = !!@value.sub!("two_digits_", "")
          if respond_to? obj.mask
            if two_digits
              @value.sub! "{two_digits_#{mask}}", format('%02d', obj.send(mask))
            else
              @value.sub! "{#{mask}}", obj.send(mask)
            end
          else
            raise InvalidMask.new mask, obj
          end
        end
      end
    end

    def unmasked
      @value
    end
  end
end
