class BookChef

  class Parser

    require "nokogiri"

    # Finds all <section src="..."> tags in BookChef xml files
    # and replaces them with the actual content from that source.
    # Outputs one single file merged out of all source files.
    class TreeMerger

      def initialize(path, fn)
        @path     = path
        @filename = fn
        @document = Nokogiri::XML.parse File.new("#@path/#@filename", "r")
      end

      def run
        @document = process_level(@document)
      end

      def save_to(fn)
        f = File.open(fn, "w")
        f.write @document.to_s
        f.close
      end

      private

        def process_level(level_document, current_path="")
          sourced_sections = level_document.xpath('//section[@src]')
          unless sourced_sections.empty?
            sourced_sections.each do |s|
              current_fn   = (s[:src].match(/[^\/]*\.xml\Z/) || ["index.xml"])[0]
              current_dir  = s[:src].sub(/\/?[^\/]*\.xml\Z/, '')
              current_path += "/#{current_dir}" unless current_dir.empty?
              
              # Parse the sourced file
              sourced_document = Nokogiri::XML.parse(File.new("#@path#{current_path}/#{current_fn}"))

              # Now process it too, replacing all src-s with xml from sourced files
              sourced_document = process_level(sourced_document, current_path)

              # replace the contents of the tag with the actual sourced file
              s.children = sourced_document.root.children
            end
          end
          return level_document
        end
      
    end

    class XSLTConverter
    end

  end

end
