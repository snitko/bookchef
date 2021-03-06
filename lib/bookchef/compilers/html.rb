class BookChef
  class Compiler
    
    # Converts XML into HTML using xslt
    class HTML

      attr_reader :document, :result

      def initialize(fn, xslt_stylesheet="#{BookChef::LIB_PATH}/stylesheets/xslt/bookchef_to_html.xsl")
        xslt_stylesheet = File.read(xslt_stylesheet).sub('#{gem_path}', "file://#{BookChef::LIB_PATH}")
        @document     = XML::XSLT.new
        @document.xml = fn
        @document.xsl = xslt_stylesheet
      end

      def run
        @result = BookChef.decode_special_chars(@document.serve)
        @result = BookChef.replace_https_with_http(@result)
      end

      def save_to(fn)
        f = File.open(fn, "w")
        f.write @result 
        f.close
      end

    end

  end
end
