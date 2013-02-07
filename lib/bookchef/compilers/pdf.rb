class BookChef
  class Compiler
    
    # Converts HTML into PDF using PDFKit
    class PDF

      require "tmpdir"
      require 'digest/md5'

      def initialize(html_input, options = {})
        
        @html_input = html_input
        default_options = {
          output_file:        "/tmp/output.pdf",
          footer_html_file:   "#{BookChef::LIB_PATH}/templates/footer.html",
          footer_custom_html: ""
        }
        @options = default_options.merge(options)

        create_footer

        @pdf = PDFKit.new(
          @html_input,
          enable_external_links: true,
          enable_internal_links: true,
          footer_html: @options[:temp_footer_filename]
        )

      end

      def compile
        @pdf.to_file(@options[:output_file])
        after_compile
      end


      private

        def create_footer
          # Taking Footer CSS from the html_input css
          stylesheet_tag = @html_input.match(/<link href=".*?" rel="stylesheet" type="text\/css"\/?>/)

          footer_html                     = File.read(@options[:footer_html_file])
          @options[:temp_footer_filename] = "#{Dir.tmpdir}/bookchef_footer_#{Digest::MD5.hexdigest(Time.now.to_s)}_#{rand(100)}.html"
          
          File.open(@options[:temp_footer_filename], "w") do |f|
            footer_html.gsub!('#{footer_text}', @options[:footer_custom_html])
            footer_html += stylesheet_tag.to_s if stylesheet_tag # Applying css to Footer
            f.write footer_html
          end
        end

        def after_compile
          File.unlink(@options[:temp_footer_filename]) if File.exists?(@options[:footer_html_file])
        end

    end

  end
end
