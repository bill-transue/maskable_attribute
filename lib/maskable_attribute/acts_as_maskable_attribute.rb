module MaskableAttribute
  module ActsAsMaskableAttribute

    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      ##
      # Specifies an attribute to be masked, followed by masks to be made available to the attribute.
      #
      # ==== Examples
      #
      # class Foo < ActiveRecord::Base
      #   maskable_attrribute :some_attribute, [ :some_method_be_used_as_a_mask, :another_attribute_mask ]
      # end

      def maskable_attribute(attribute_to_mask, masks)
        raise ArgumentError, "invalid argument (expected attribute)" unless column_names.include? attribute_to_mask.to_s

        cattr_accessor :masks
        self.masks ||= {}
        self.masks[attribute_to_mask] = masks
        self.masks

        define_method attribute_to_mask do
          masked_attribute attribute_to_mask
        end

        define_method "#{attribute_to_mask}=" do |value|
          write_attribute attribute_to_mask, masked_attribute(attribute_to_mask).set(value)
        end
      end
    end

    attr_accessor :masked_attribute

    def masked_attribute(attribute)
      @masked_attribute ||= MaskableAttribute.new self, attribute, self.class.masks[attribute]
    end
  end
end

ActiveRecord::Base.send :include, MaskableAttribute::ActsAsMaskableAttribute
