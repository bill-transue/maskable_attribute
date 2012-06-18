require 'test_helper'

class HickwellTest < ActiveSupport::TestCase
  def setup
    @hickwell = Hickwell.create!
  end

  test "should have 4 attributes, foo, bar, baz, qux" do
    assert Hickwell.column_names.include?("foo"), "Missing attribute: foo"
    assert Hickwell.column_names.include?("bar"), "Missing attribute: bar"
    assert Hickwell.column_names.include?("baz"), "Missing attribute: baz"
    assert Hickwell.column_names.include?("qux"), "Missing attribute: qux"
  end

  test "should have maskable_attribute qux" do
    assert @hickwell.qux.is_a?(MaskableAttribute::MaskableAttribute), "Masked attribute isn't a MaskableAttribute"
  end

  test "should have getter and setter methods for qux" do 
    assert_respond_to @hickwell, :qux,  "No getter method"
    assert_respond_to @hickwell, :qux=, "No setter method"
  end

  test "should have a quux method" do
    assert @hickwell.respond_to? :quux, "Missing quux method"
  end

  test "returns 'thud' from quux method" do
    assert_equal 'thud', @hickwell.quux, "#quux not returning 'thud'"
  end
end
