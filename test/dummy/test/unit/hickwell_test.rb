require 'test_helper'

class HickwellTest < ActiveSupport::TestCase
  def setup
    @hickwell = Hickwell.create!
  end

  test "should have maskable_attribute foo" do
    assert @hickwell.foo.is_a?(MaskableAttribute), "Masked attribute isn't a MaskableAttribute"
  end
end
