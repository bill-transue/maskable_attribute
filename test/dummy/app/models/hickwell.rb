class Hickwell < ActiveRecord::Base
  maskable_attribute :qux, [ :foo, :bar, :baz ]
  def quux
    "thud"
  end
end
