class BookChef
  class Compiler
    
    # Converts XML into HTML using xslt
    class HTML

      @@lib_path = File.expand_path(File.dirname(__FILE__) + "../../")

      require 'xml/xslt'
      attr_reader :document, :result

      def initialize(fn, xslt_stylesheet="#{@@lib_path}/stylesheets/xslt/bookchef_to_html.xsl")
        xslt_stylesheet = File.read(xslt_stylesheet).sub('#{gem_path}', "file://#{@@lib_path}/images")
        @document     = XML::XSLT.new
        @document.xml = fn
        @document.xsl = xslt_stylesheet
      end

      def run
        @result = @document.serve
      end

      def save_to(fn)
        f = File.open(fn, "w")
        f.write @result
        f.close
      end

    end

  end
end
