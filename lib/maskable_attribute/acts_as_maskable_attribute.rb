module MaskableAttribute
  module ActsAsMaskableAttribute
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      ##
      # Specifices an attribute to be masked, followed by masks to be made available to the attribute.
      #
      # ==== Examples
      #
      # class Foo < ActiveRecord::Base
      #   maskable_attrribute :some_attribute, :some_method_be_used_as_a_mask, :another_attribute_mask
      # end
      def maskable_attribute(masked_attribute, *masks)
        cattr_accessor :masked_attributes, :masks
        self.masked_attributes ||= Hash.new
        self.masked_attributes[masked_attribute] = MaskableAttribute.new masks
        self.masks ||= {}
        self.masks[masked_attribute] = masks
        self.send(:define_method, name.to_s) { maskable_attributes[masked_attribute] }
        self.send(:define_method, name.to_s + "=") { |value| maskable_attributes[masked_attribute] = value }
      end
    end
  end
end

ActiveRecord::Base.send :include, MaskableAttribute::ActsAsMaskableAttribute
