require 'test_helper'

class FormattingTest < ActiveSupport::TestCase

  #describe Format
  test "should accept a symbol as the format method" do
    format = MaskableAttribute::Formatting::Format.new :upcase
    assert_equal "SUCCESS", format.apply("success")
  end

  test "should accept a Proc as the format method" do
    format = MaskableAttribute::Formatting::Format.new Proc.new { |value| value.upcase }
    assert_equal "SUCCESS", format.apply("success")
  end

  test "should return nil when formatting methods raise exceptions" do
    format = MaskableAttribute::Formatting::Format.new Proc.new { |value| raise 'I meant to do this...' }

    assert_nothing_raised do
      assert_nil format.apply("success")
    end
  end

  #describe Formats
  test "should accept a hash of a single format" do
    formats = MaskableAttribute::Formatting::Formats.new :formats => :upcase

    assert_equal "SUCCESS", formats[:upcase].apply("success")
  end

  test "should accept a hash of an array of formats" do
    formats = MaskableAttribute::Formatting::Formats.new :formats => [ :upcase, :downcase ]

    assert_equal "SUCCESS", formats[:upcase].apply("success"), "First element not assigned as name/method"
    assert_equal "success", formats[:downcase].apply("SUCCESS"), "Second element not assigned as name/method"
  end

  test "should accept a hash of a hash with a symbol as a value" do
    formats = MaskableAttribute::Formatting::Formats.new :formats => { :upcased => :upcase }

    assert_equal "SUCCESS", formats[:upcased].apply("success")
  end

  test "should accept a hash of a hash of formats" do
    formats = MaskableAttribute::Formatting::Formats.new :formats => { :two_digit => Proc.new { |value| format '%02d', value },
                                                                       :upcased => :upcase,
                                                                       :downcase => nil }

    assert_equal '01', formats[:two_digit].apply(1), "Proc not used as method"
    assert_equal "SUCCESS", formats[:upcased].apply("success"), "Symbol not used as method"
    assert_equal "success", formats[:downcase].apply("SUCCESS"), "Name, in leu of nil, not used as method"
  end

  test "should recognize exclusive formats" do
    formats = MaskableAttribute::Formatting::Formats.new :exclusive_formats => [ :upcase, :downcase ]

    assert formats.are_exclusive?, "Did not recognize exclusive formats"
  end

  test "should recognize a default_format" do
    formats = MaskableAttribute::Formatting::Formats.new :default_format => :upcase

    assert formats.has_default?
    assert_equal formats[:upcase], formats.default, "Default format not assigned"
    assert_equal 'SUCCESS', formats.default.apply("success"), "Default format not applied"
  end

  test "should be able to use a block for applying formats" do
    formats = MaskableAttribute::Formatting::Formats.new :formats => :upcase

    assert_equal 'SUCCESS', formats.apply(:upcase) { "success" }
  end

  test "should provide all format names" do
    formats = MaskableAttribute::Formatting::Formats.new :formats => [ :upcase, :downcase ]

    assert_equal [ :upcase, :downcase ], formats.names, "Did not provide all format names"
  end
end
