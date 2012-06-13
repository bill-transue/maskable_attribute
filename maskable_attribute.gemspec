# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "maskable_attribute/version"

Gem::Specification.new do |s|
  s.name        = "maskable_attribute"
  s.version     = MaskableAttribute::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Bill Transue"]
  s.email       = ["transue@gmail.com "]
  s.homepage    = "https://github.com/billy-ran-away/maskable_attribute"
  s.summary     = %q{Allows Ruby on Rails to have a maskable attribute.}
  s.description = %q{A maskable attribute is an attribute that is made up of other attributes (masks), this ordering is set in the masked attribute and preserved across updates.}

  s.rubyforge_project = "maskable_attribute"
  s.add_dependency "rails", ">= 2.3.10"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
