class BookChef
  class Compilers
    
    # Converts HTML into PDF using PDFKit
    class PDF

      require "pdfkit"

      def initialize(html_input, css="lib/bookchef/stylesheets/css/default.css", output_file="output.pdf")
        @pdfkit = PDFKit.new(html_input, :page_size => 'Letter')
        @pdfkit.stylesheets << "#{Dir.getwd}/#{css}" if css
        @output_file        = output_file
      end

      def compile
        @pdfkit.to_file "#{Dir.getwd}/#@output_file"
      end

    end

  end
end
