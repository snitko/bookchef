require "rubygems"

require "nokogiri"
require "xml/xslt"
require "pdfkit"

require "bookchef/tree_merger"
require "bookchef/compilers/html"
require "bookchef/compilers/pdf"

class BookChef
  LIB_PATH = File.expand_path(File.dirname(__FILE__) + "/bookchef")
end
