class BookChef
  class Compiler
    
    # Converts HTML into PDF using PDFKit
    class PDF

      def initialize(html_input, output_file="/tmp/output.pdf", css="lib/bookchef/stylesheets/css/default.css")
        @pdfkit = PDFKit.new(html_input, :page_size => 'Letter')
        @pdfkit.stylesheets << "#{Dir.getwd}/#{css}" if css
        @output_file        = output_file
      end

      def compile
        @pdfkit.to_file @output_file
      end

    end

  end
end
