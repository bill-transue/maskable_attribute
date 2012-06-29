require 'test_helper'

class MaskTest < ActiveSupport::TestCase

  #describe mask
  test "should accept symbol as both a name and its method" do
    mask = MaskableAttribute::Mask.new :upcase

    assert_equal "upcase", mask.name
    assert_equal 'SUCCESS', mask.unmask('success')
  end

  test "should accept symbol as a name and method in its hash" do
    mask = MaskableAttribute::Mask.new :lowercase => :downcase

    assert_equal 'lowercase', mask.name
    assert_equal 'success', mask.unmask('SUCCESS')
  end

  test "should accept proc as a method in its hash" do
    mask = MaskableAttribute::Mask.new :lowercase => Proc.new { |value| value.downcase }

    assert_equal 'lowercase', mask.name
    assert_equal 'success', mask.unmask('SUCCESS')
  end

  test "should accept a hash of hash for options" do
    mask = MaskableAttribute::Mask.new :downcase => { :formats => { :capitalized => :capitalize } }

    assert_equal 'downcase', mask.name
    assert_equal 'Success', mask.unmask('SUCCESS', :formatted => :capitalized)
  end

  test "should accept a hash of an array for options" do
    mask = MaskableAttribute::Mask.new :lowercase => [ :downcase, { :formats => :capitalize } ]

    assert_equal 'lowercase', mask.name
    assert_equal 'Success', mask.unmask('SUCCESS', { :formatted => :capitalize })
  end

  test "should turn spaces into underscores for its name" do
    mask = MaskableAttribute::Mask.new :"foo bar" => :foo_bar

    assert_equal "foo_bar", mask.name
    assert_equal :foo_bar, mask.method
  end

  test "should return all accessed_by names" do
    mask = MaskableAttribute::Mask.new :downcase => { :formats => { :capitalized => :capitalize } }

    assert_equal ["capitalized_downcase", "downcase"], mask.accessed_by
  end

  test "should return all formatted exclusively accessed_by names" do
    mask = MaskableAttribute::Mask.new :downcase => { :exclusive_format => { :capitalized => :capitalize } }

    assert_equal ["capitalized_downcase"], mask.accessed_by
  end

  test "should determine whether a string matches its accessible names" do
    mask = MaskableAttribute::Mask.new :downcase => { :exclusive_format => { :capitalized => :capitalize } }

    assert !mask.accessed_by?("downcase")
    assert mask.accessed_by?("capitalized_downcase")
  end

  test "should accept two word formats with two word masks" do
    mask = MaskableAttribute::Mask.new :down_cased => [ :downcase, :formats => { :capitalized_but => :capitalize } ]

    assert mask.accessed_by?("capitalized_but_down_cased")
    assert_equal 'Success', mask.unmask('SUCCESS', :formatted => :capitalized_but)
  end

  #describe masks
  test "should find correct mask by accessor" do
    masks = MaskableAttribute::Masks.new [ { :bar => { :exclusive_format => { :capitalized => :capitalize } } },
                                           { :baz => { :format => :upcase } } ]

    assert_equal "bar", masks.find_by_accessor("capitalized bar").name
  end

  test "should be accessible by accessor" do
    masks = MaskableAttribute::Masks.new [ { :bar => { :exclusive_format => :capitalize } },
                                           { :baz => { :format => :upcase } } ]

    assert_equal "baz", masks["upcase baz"].name
  end

  test "should unmask given object with correct mask and its exlusive format" do
    masks = MaskableAttribute::Masks.new [ { :downcase => { :exclusive_format => :capitalize } },
                                           { :bar => { :format => :upcase } } ]

    assert_equal "Success", masks["capitalize downcase"].unmask("SUCCESS")
  end

  test "should return nil when trying to access and get value of a non-existent mask" do
    masks = MaskableAttribute::Masks.new [ :downcase => { :exclusive_format => { :capitalized => :capitalize } },
                                           :bar => { :format => :upcase } ]

    assert_nil masks["not a real mask"].unmask("nil is success!"), "This will probably be an error..."
  end
end
