require "rubygems"

require "nokogiri"
require "xml/xslt"
require "pdfkit"

require "bookchef/tree_merger"
require "bookchef/compilers/html"
require "bookchef/compilers/pdf"

class BookChef
  LIB_PATH = File.expand_path(File.dirname(__FILE__) + "/bookchef")

  class << self

    # Converts XML special characrters into temporary identifiable entities
    # for later backwards conversion by BookChef compilers.
    def protect_special_chars(s)
      # erb tags
      s.gsub!(/<%(.*?)%>/, '#lt;%\1%#gt;')
      # all xml entities
      s.gsub!(/&([a-zA-Z0-9#]*?);/, '#\1;')
      # standalone ampersand chars
      s.gsub!('&', '#amp;')
      return s
    end

    def decode_special_chars(s)
      s.gsub(/#([a-zA-Z0-9#]*?);/, '&\1;')
    end

  end

end
