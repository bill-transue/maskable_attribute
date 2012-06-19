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
    assert_equal "{foo}{bar}{baz}", @hickwell.read_attribute(:qux), "Couldn't set masking of attribute"
  end

  test "should not overwrite attribute with unmasked attribute" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"

    assert_equal "abc", @hickwell.qux.to_s
    assert_equal "abc", @hickwell.qux.to_s
    assert_equal "{foo}{bar}{baz}", @hickwell.read_attribute(:qux), "Overwriting attribute with unmasked value"
  end

  test "should be able to get attribute masked (by default)" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"

    assert_equal "abc", @hickwell.qux.to_s, "Couldn't get attribute masked"
  end

  test "should be able to get attribute unmasked" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"

    assert_equal "{foo}{bar}{baz}", @hickwell.qux.unmasked, "Could not get attribute unmasked"
  end

  test "should be able to get set value of attribute and have masks persist" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"
    @hickwell.qux = "bac"

    assert_equal "{bar}{foo}{baz}", @hickwell.qux.unmasked, "Masks didn't persist though update"
  end

  test "masks should be able to reference differently named methods" do
    class Rickwell < Hickwell
      maskable_attribute :bar, :qux => :quux
    end

    @hickwell = Rickwell.create! :bar => "{qux}"

    assert_equal "thud", @hickwell.bar.to_s
  end

  test "masks should be able to reference a Proc block" do
    class Wickwell < Hickwell
      maskable_attribute :baz, :ack => Proc.new { "syn" }
    end

    @hickwell = Wickwell.create! :baz => "{ack}"

    assert_equal "syn", @hickwell.baz.to_s
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
