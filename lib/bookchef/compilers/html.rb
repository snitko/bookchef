class BookChef
  class Compiler
    
    # Converts XML into HTML using xslt
    class HTML

      @@lib_path = File.expand_path(File.dirname(__FILE__) + "../../")
      attr_reader :document, :result

      def initialize(fn, xslt_stylesheet="#{@@lib_path}/stylesheets/xslt/bookchef_to_html.xsl")
        xslt_stylesheet = File.read(xslt_stylesheet).sub('#{gem_path}', "file://#{@@lib_path}")
        @document     = XML::XSLT.new
        @document.xml = fn
        @document.xsl = xslt_stylesheet
      end

      def run
        @result = @document.serve
        @result.gsub!("&amp;lt;", "&lt;")
        @result.gsub!("&amp;gt;", "&gt;")
      end

      def save_to(fn)
        f = File.open(fn, "w")
        f.write @result
        f.close
      end

    end

  end
end
