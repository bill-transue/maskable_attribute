# Maskable Attribute

maskable_attribute is an ActiveRecord extension that allows for 'masking' a records' attribute. It provides the ability to have an objects' attribute be dynamically assigned at a given point in time while providing the capability to make a one-location change that propagates through all resulting objects containing the resulting attribute mask.

## Install

### Via rubygems:

    gem install maskable_attribute

### Via bundler:

  Add the following line to Gemfile:

    gem 'maskable_attribute'

  Then, run bundler:

    bundle install

## Usage

To use the maskable_attribute gem, simply create corresponding maskable_attribute attributes in the ActiveRecord model that you wish to affect.

For example, the following User class has a maskable attribute of :foo that can contain values of :bar, :baz and :qux

    class User < ActiveRecord::Base
      maskable_attribute :foo, [ :bar, :baz ]
    end

Creating a user with the above mask can be performed via the following:

    user = User.new :bar => "a", :baz => "b", :foo => "{bar}-{baz}"

Now that the user object is created, there are several accessor methods to return different variations of the attribute:

    user.masks              # { :foo => { :bar, :baz } }
    user.foo.masks          # [ :bar, :baz ]
    user.foo                # "a-b"
    user.foo.unmasked       # "{bar}-{baz}"

## Supported Ruby versions

Maskable Attribute supports Ruby 1.9.x+

## Additional Information

* [Git](https://github.com/billy-ran-away/maskable_attribute)

## Contributing

Contributions to the code-base are welcomed and handled via the normal Github pull request process.

## Owner

maskable_attribute is written and maintained by Bill Transue
