require 'radiant-grandchildren_tags-extension/version'
class GrandchildrenTagsExtension < Radiant::Extension
  version RadiantGrandchildrenTagsExtension::VERSION
  description "Adds grandchildren tags to Radiant."
  url "http://github.com/jomz/radiant-grandchildren_tags-extension"
  
  def activate
    Page.send :include, GrandchildrenTags
  end
end
