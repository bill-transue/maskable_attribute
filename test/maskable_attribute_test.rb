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

    assert_respond_to @hickwell.maskable_qux, :masks, "Couldn't get available masks"
  end

  test "should get available masks" do
    @hickwell = Hickwell.create!

    assert_equal [ :foo, :bar, :baz ], @hickwell.maskable_qux.masks, "Masks method did not return list of masks"
  end

  test "should have masked_object available to itself" do
    @hickwell = Hickwell.create!

    assert_equal @hickwell, @hickwell.maskable_qux.masked_object, "Couldn't determine the masked object"
  end

  test "should be able to set masking of attribute" do
    @hickwell = Hickwell.create!

    @hickwell.qux = "{foo}{bar}{baz}"
    assert_equal "{foo}{bar}{baz}", @hickwell.read_attribute(:qux), "Couldn't set masking of attribute"
  end

  test "should not overwrite attribute with unmasked attribute" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"

    assert_equal "abc", @hickwell.qux
    assert_equal "abc", @hickwell.qux
    assert_equal "{foo}{bar}{baz}", @hickwell.read_attribute(:qux), "Overwriting attribute with unmasked value"
  end

  test "should be able to get attribute masked (by default)" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"

    assert_equal "abc", @hickwell.qux, "Couldn't get attribute masked"
  end

  test "should be able to get attribute unmasked" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"

    assert_equal "{foo}{bar}{baz}", @hickwell.maskable_qux.unmasked, "Could not get attribute unmasked"
  end

  test "should be able to get set value of attribute and have masks persist" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"
    @hickwell.qux = "bac"

    assert_equal "{bar}{foo}{baz}", @hickwell.maskable_qux.unmasked, "Masks didn't persist though update"
  end

  test "masks should be able to reference differently named methods" do
    class Rickwell < Hickwell
      maskable_attribute :bar, :qux => :quux
    end

    @hickwell = Rickwell.create! :bar => "{qux}"

    assert_equal "thud", @hickwell.bar
  end

  test "should allow maskable_attribute to be nil" do
    @hickwell = Hickwell.create! :foo => "a", :bar => "b", :baz => "c", :qux => "{foo}{bar}{baz}"
    @hickwell.qux = nil

    assert_nil @hickwell.qux, "Maskable attribute not set to nil"
  end

  test "masks should be able to reference a Proc block" do
    class Wickwell < Hickwell
      maskable_attribute :baz, :ack => Proc.new { "syn" }
    end

    @hickwell = Wickwell.create! :baz => "{ack}"

    assert_equal "syn", @hickwell.baz
  end

  test "masks should be able to handle multiple words" do
    class Dickwell < Hickwell
      maskable_attribute :bar, :foo_bar => Proc.new { "syn" }
    end

    @hickwell = Dickwell.create! :bar => "{foo_bar}"

    assert_equal "syn", @hickwell.bar, "Did not retrieve mask for multiple words"
  end

  test "masks should be able to handle multiple words with spaces" do
    class Zickwell < Hickwell
      maskable_attribute :bar, :foo_bar => Proc.new { "syn" }
    end

    @hickwell = Zickwell.create! :bar => "{foo bar}"

    assert_equal "syn", @hickwell.bar, "Did not retrieve mask for multiple words with spaces"
  end

  test "masks should be able to directly reference methods for the class object" do
    class Fickwell < Hickwell
      maskable_attribute :bar, [ :foo_bar_baz ]

      def foo_bar_baz
        "ack one"
      end
    end
    @fickwell = Fickwell.create! :bar => "{foo bar baz}"

    assert_equal "ack one", @fickwell.bar, "Did not retrieve mask for object method reference"
  end

  test "masks should be able to directly reference aliased methods for the class object" do
    class Fickwell < Hickwell
      maskable_attribute :bar, [ :fbb ]

      def foo_bar_baz
        "syn two"
      end

      alias :fbb :foo_bar_baz
    end
    @hickwell = Fickwell.create! :bar => "{fbb}"

    assert_equal "syn two", @hickwell.bar, "Did not retrieve mask for object aliased method reference"
  end

  test "should be able to handle masks for non-string types" do
    class Nickwell < Hickwell
      maskable_attribute :baz, [ :number ]

      def number
        5
      end
    end
    @hickwell = Nickwell.create! :baz => "fixture {number}"

    assert_equal "fixture 5", @hickwell.baz, "Could not handle non-string type mask"
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

  test "should be able to handle a proc and a format" do
    class Tickwell < Hickwell
      maskable_attribute :bar, { :foo => {
                                   :method => Proc.new { "2" },
                                   :default_format => Proc.new { |value| format "%02d", value }
                                 }
                               }
    end

    @hickwell = Tickwell.create! :bar => "{foo}"

    assert_equal "02", @hickwell.bar, "Did not retrieve mask having a proc and a format specified"
  end

  test "should not confuse masks' formatting" do
    class Pickwell < Hickwell
      maskable_attribute :bar, { :foo => {
                                   :method => Proc.new { "2" },
                                   :format => { :two_digit => Proc.new { |value| format "%02d", value } }
                                 }
                               }
    end

    @pickwell = Pickwell.create! :bar => "{foo}"

    assert_equal "2", @pickwell.bar
    @pickwell.bar = "2"
    assert_equal "{foo}", @pickwell.maskable_bar.unmasked
    @pickwell.bar = "02"
    assert_equal "{two_digit_foo}", @pickwell.maskable_bar.unmasked
    assert_equal "02", @pickwell.bar
  end
end
