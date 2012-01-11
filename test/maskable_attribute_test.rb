require 'test_helper'

class MaskableAttributeTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, MaskableAttribute
  end

  test "should be able to set an attribute to be maskable" do
    assert_respond_to Hickwell, :maskable_attribute, "Can't mask an attribute"
  end

  test "should be able to get available masks" do
    @hickwell = Hickwell.create!

    assert_respond_to @hickwell.qux, :masks, "Couldn't get available masks"
  end

  test "should get available masks" do
    @hickwell = Hickwell.create!

    assert_equal [ :foo, :bar, :baz ], @hickwell.qux.masks, "Masks method did not return list of masks"
  end

  test "should have masked_object available to itself" do
    @hickwell = Hickwell.create!

    assert_equal @hickwell, @hickwell.qux.masked_object, "Couldn't determine the masked object"
  end

  test "should be able to set masking of attribute" do
    @hickwell = Hickwell.create!

    @hickwell.qux = "{foo}{bar}{baz}"
    assert_equal "{foo}{bar}{baz}", @hickwell.read_attribute(:qux), "Couln't set masking of attribute"
  end

  test "should be able to get attribute masked (by default)" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"
    
    assert_equal "abc", @hickwell.qux.to_s, "Couldn't get attribute masked"
  end

  test "should be able to get attribute unmasked" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"

    assert_equal "{foo}{bar}{baz}", @hickwell.qux.unmasked, "Could get attribute unmasked"
  end

  test "should be able to get set value of attribute and have masks perist" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"
    @hickwell.qux = "abc"

    assert_equal "{foo}{bar}{baz}", @hickwell.qux.unmasked, "Masks didn't perist though update"
  end

  test "should raise exception if maskable_attribute isn't actually an attribute" do
    assert_raise ArgumentError do
      Hickwell.maskable_attribute :fail, [ :foo, :bar, :baz ]
    end
  end

  test "should raise exception if no masks are passed" do
    assert_raise ArgumentError do
      Hickwell.maskable_attribute :qux
    end
  end
end
