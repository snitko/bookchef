class BookChef
  class Compiler
    
    # Converts HTML into PDF using PDFKit
    class PDF

      def initialize(html_input, output_file="/tmp/output.pdf", css="lib/bookchef/stylesheets/css/default.css")
        @pdf         = PDFKit.new(html_input, enable_external_links: true, enable_internal_links: true)
        @output_file = output_file
      end

      def compile
        @pdf.to_file(@output_file)
      end

    end

  end
end
