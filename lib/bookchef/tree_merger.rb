class BookChef

  class TreeMerger

    attr_reader :document

    class LinkLevelOutOfReach < Exception; end

    def initialize(path, fn)
      @path     = File.expand_path(path)
      @filename = fn
      @document = File.read("#@path/#@filename").gsub(/<%(.*?)%>/, '&lt;%\1%&gt;')
      @document = Nokogiri::XML.parse @document
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
        sourced_sections = level_document.xpath('//section[@src]|//chapter[@src]')

        normalize_code!            level_document
        convert_links!             level_document, current_path
        make_image_paths_absolute! level_document, current_path
        
        sourced_sections.each do |s|
          current_fn        = filename_or_index(s[:src])
          current_dir       = s[:src].sub(/\/?[^\/]*\.xml\Z/, '')
          path = current_path
          path              += "/#{current_dir}" unless current_dir.empty?
          full_current_path = "#{path}/#{current_fn}"
          
          puts "processing #{full_current_path}" 
          assign_id_to_section! s, full_current_path
          
          # Parse the sourced file
          sourced_document = Nokogiri::XML.parse(File.read("#@path#{full_current_path}").gsub(/<%(.*?)%>/, '&lt;%\1%&gt;'))
          convert_references_and_footnotes! sourced_document, full_current_path

          # Now process it too, replacing all src-s with xml from sourced files
          sourced_document = process_level(sourced_document, path)

          # replace the contents of the tag with the actual sourced file
          s.children = sourced_document.root.children
        end unless sourced_sections.empty?

        return level_document
      end

      # Converts links 'href' attr from relative to absolute path
      # according to the sections 'name' attrs.
      def convert_links!(document, current_path)
        document.search("a").each do |link|
          next if link[:href].nil? || link[:href] =~ /\Ahttp:\/\//
          path_arr = link[:href].split("/")
          uplevels_count = (path_arr.map { |i| i if i == ".." }).compact.size
          
          if uplevels_count >= current_path.split("/").size
            raise LinkLevelOutOfReach, "for link #{link.to_s} in \"#{current_path}\""
          end

          path_arr.delete_at(-1) if path_arr[-1] =~ /\.xml\Z/
          new_path    =  path_arr[uplevels_count..path_arr.size-1].join("/")
          new_path    += "/" unless new_path.empty?
          link[:href] =  "#/" + new_path + filename_or_index(link[:href])
        end
      end

      def convert_references_and_footnotes!(document, current_path)
        document.search("//footnote|//reference").each do |node|
          node[:id] = current_path + "/#{node.name}_#{node[:id]}"
        end
        document.search("//@footnote|//@reference").each do |node|
          node.parent["number"]  = node.value
          node.parent[node.name] = current_path + "/#{node.name}_#{node.value}"
        end
      end

      def make_image_paths_absolute!(document, current_path)
        document.search("img").each do |img|
          img[:src] = "file://" + @path + current_path + "/#{img[:src]}"
        end
      end

      # Sets section id like this: <section id="/section1/subsection_a/intro.xml">
      def assign_id_to_section!(node, full_current_path)
        node[:id] = full_current_path
        node.remove_attribute("src")
      end

      def filename_or_index(path)
        (path.match(/[^\/]*\.xml\Z/) || ["index.xml"])[0]
      end

      def normalize_code!(document)
        document.search("code").each do |c|
          minimum_whitespace = nil
          lines_arr = c.children.to_s.split("\n")
          new_lines_arr = []
          lines_arr.each_with_index do |l,i|
            next if l =~ /\A\s*\Z/
            match_size = l.match(/\A( )*/).to_s.size
            minimum_whitespace = match_size if !minimum_whitespace || match_size < minimum_whitespace
          end
          lines_arr.each_with_index do |l,i|
            next if l =~ /\A\s*\Z/ && (i == 0 || i == lines_arr.size-1)
            l.sub!("\n", '')
            l.sub!(/\A( ){#{minimum_whitespace}}/, '')
            new_lines_arr << split_long_line(l, l.match(/\A( )*/).to_s.size)
          end
          c.content = new_lines_arr.compact.join("\n")
        end
      end

      def split_long_line(line, leading_spaces_number=0)
        if line.length > 70
          lines = line[61..line.length-1].split(/[ .]/, 2)
          line1 = line[0..60] + lines[0]
          leading_spaces = (0..leading_spaces_number-1).map { ' ' }.join
          line2 = leading_spaces.to_s + lines[1].to_s
          line2 = split_long_line(line2, leading_spaces_number)
          return "#{line1}\n#{line2}"
        else
          line
        end
      end

  end

end
