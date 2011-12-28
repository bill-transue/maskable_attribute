module MaskableAttribute
  module ActsAsMaskableAttribute
    extend ActiveSupport::Concern

    included do
    end

    module ClassMethods
      def maskable_attribute(masked_attribute, *masks)
        cattr_accessor :masked_attributes, :masks
        self.masked_attributes ||= Hash.new
        self.masked_attributes[masked_attribute] = nil
        self.masks ||= Hash.new
        self.masks[masked_attribute] = Array.wrap masks
      end
    end
  end
end

ActiveRecord::Base.send :include, MaskableAttribute::ActsAsMaskableAttribute
