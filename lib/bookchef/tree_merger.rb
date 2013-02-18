class BookChef

  class TreeMerger

    attr_reader :document, :version

    class LinkLevelOutOfReach < Exception; end

    def initialize(path, fn)
      @path     = File.expand_path(path)
      @filename = fn
      @document = File.read("#@path/#@filename").gsub(/<%(.*?)%>/, '&lt;%\1%&gt;')
      @document = Nokogiri::XML.parse @document
      insert_version_from_git_tag!
      if File.exists?("#@path/settings.xml")
        @settings = File.read("#@path/settings.xml") 
        @document.root << @settings
      end
    end

    def run
      @documents = []
      @document  = process_level(@document)
    end

    def save_to(fn)
      f = File.open(fn, "w")
      f.write @document.to_s
      f.close
    end

    private

      def process_level(level_document, current_path="")
        @documents << level_document
        sourced_sections = level_document.xpath('//section[@src]|//chapter[@src]')

        normalize_code!            level_document
        convert_links!             level_document, current_path
        make_image_paths_absolute! level_document, current_path
        
        sourced_sections.each do |s|
          current_fn        = filename_or_index(s[:src])
          current_dir       = s[:src].sub(/\/?[^\/]*\.xml\Z/, '')
          path              = current_path
          path              += "/#{current_dir}" unless current_dir.empty?
          full_current_path = "#{path}/#{current_fn}"
          
          puts "processing #{full_current_path}" 
          assign_id_to_section! s, full_current_path
          
          # Parse the sourced file
          level_file = File.read("#@path#{full_current_path}")
          level_file = BookChef.protect_special_chars(level_file)
          sourced_document = Nokogiri::XML.parse(level_file)
          convert_references_and_footnotes! sourced_document, full_current_path

          # Now process it too, replacing all src-s with xml from sourced files
          sourced_document = process_level(sourced_document, path)

          # replace the contents of the tag with the actual sourced file
          s.children = sourced_document.root.children
        end unless sourced_sections.empty?

        @documents.delete(level_document) and return level_document
      end

      # Converts links 'href' attr from relative to absolute path
      # according to the sections 'name' attrs.
      def convert_links!(document, current_path)
        document.search("a").each do |link|

          next if link[:href].nil? || link[:href] =~ /\Ahttps?:\/\//
          link_path_arr    = link[:href].split("/")
          current_path_arr = current_path.split("/").reject { |i| i.empty? }
          uplevels_count   = (link_path_arr.map { |i| i if i == ".." }).compact.size
          link_path_arr.delete_if { |i| i == ".." }

          if uplevels_count > current_path_arr.size
            raise LinkLevelOutOfReach, "for link #{link.to_s} in \"#{current_path}\""
          end

          current_path_arr = current_path_arr.reverse.drop(uplevels_count).reverse
          link[:href] = "#/#{current_path_arr.join("/")}/#{path_with_filename(link_path_arr.join("/"))}".gsub(/\/+/, '/')
        end
      end

      def convert_references_and_footnotes!(document, current_path)
        
        # Search the document tree and find the closest file
        # that contains <footnotes> and <references>
        container_paths = { footnote: current_path.split("/"), reference: current_path.split("/") }
        [:footnote, :reference].each do |container|
          catch :break_inner_loop do
            (@documents + [document]).reverse.each_with_index do |d,i|
              throw :break_inner_loop if d.search("//#{container}s").size > 0
              container_paths[container].pop if container_paths[container].pop == "index.xml"
              container_paths["#{container}_file"] = "/index.xml"
            end
          end
        end
        
        document.search("//footnote|//reference").each do |node|
          node[:id] = current_path + "/#{node.name}_#{node[:id]}"
        end
        
        document.search("//@footnote|//@reference").each do |node|
          node.parent["number"]  = node.value
          node.parent[node.name] = container_paths[node.name.to_sym].join("/")  +
                                   (container_paths["#{node.name}_file"] || '') +
                                   "/#{node.name}_#{node.value}"
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

      # returns just the filename out of the full path
      # For example, if the path is "/section1/subsection"
      # it returns "index.xml"
      def filename_or_index(path)
        (path.match(/[^\/]*\.xml\Z/) || ["index.xml"])[0]
      end

      # returns full path attaching "index.xml" to the end of no file specified
      # For example, if the path is "/section/subsection"
      # it returns "/section/subsection/index.xml"
      def path_with_filename(path)
        if path.match(/[^\/]*\.xml\Z/)
          path
        else
          path + "/index.xml"
        end
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

      def insert_version_from_git_tag!

        `cd #{@path} && git tag`.split("\n").sort.reverse.each do |t|
          if t =~ /\Av[0-9]/
            @version = t.sub(/\Av/,'').rstrip
            @document.root["version"] = t.sub(/\Av/,'').rstrip
            return
          end
        end

      end

  end

end
