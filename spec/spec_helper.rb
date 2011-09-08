require 'rubygems'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'hoth'
require 'rspec'
require 'rspec/autorun'

RSpec::Matchers.define :string_matching do |regex|
  match do |string|
    string =~ regex
  end
end
