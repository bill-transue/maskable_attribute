require 'test_helper'

class MaskableAttributeTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, MaskableAttribute
  end

  test "should be able to set an attribute to be maskable" do
    assert_respond_to Hickwell, :maskable_attribute, "Can't mask an attribute!"
  end

  test "should be able to get available masks" do
    @hickwell = Hickwell.create!

    assert_respond_to @hickwell.qux, :masks, "Couldn't get available masks!"
  end

  test "should get available masks" do
    @hickwell = Hickwell.create!

    assert_equal [ :foo, :bar, :baz ], @hickwell.qux.masks, "Masks method did not return list of masks!"
  end

  test "should have masked_object available to itself" do
    @hickwell = Hickwell.create!

    assert_equal @hickwell, @hickwell.qux.masked_object, "Couldn't determine the masked object!"
  end
end
