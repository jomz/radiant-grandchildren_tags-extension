# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "radiant-grandchildren_tags-extension/version"

Gem::Specification.new do |s|
  s.name        = "radiant-grandchildren_tags-extension"
  s.version     = RadiantGrandchildrenTagsExtension::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Benny Degezelle"]
  s.email       = ["benny@gorilla-webdesign.be"]
  s.homepage    = "http://github.com/jomz/radiant-grandchildren_tags-extension"
  s.summary     = %q{Grandchildren Tags for Radiant CMS}
  s.description = %q{Makes Radiant better by adding grandchildren_tags!}
  
  ignores = if File.exist?('.gitignore')
    File.read('.gitignore').split("\n").inject([]) {|a,p| a + Dir[p] }
  else
    []
  end
  s.files         = Dir['**/*'] - ignores
  s.test_files    = Dir['test/**/*','spec/**/*','features/**/*'] - ignores
  # s.executables   = Dir['bin/*'] - ignores
  s.require_paths = ["lib"]
  
  s.post_install_message = %{
  Add this to your radiant project with:
    config.gem 'radiant-grandchildren_tags-extension', :version => '~>#{RadiantGrandchildrenTagsExtension::VERSION}'
  }
end