require "spec_helper"
require "equivalent-xml"

describe BookChef::Parser do

  before(:each) do
    @book_dir = File.dirname(__FILE__) + '/../../fixtures/book'
  end

  describe BookChef::Parser::TreeMerger do

    it "follows src= args in tags and merges files into one" do
      merger   = BookChef::Parser::TreeMerger.new(@book_dir, "main.xml")
      merger.run
      merger.save_to "#{@book_dir}/merge_saved.xml"
      
      merge_saved    = Nokogiri::XML.parse File.new("#{@book_dir}/merge_saved.xml")
      merge_expected = Nokogiri::XML.parse File.new("#{@book_dir}/merge_expected.xml")
      File.unlink      "#{@book_dir}/merge_saved.xml"

      merge_saved.should be_equivalent_to(merge_expected)
    end

  end

  describe BookChef::Parser::XML2HTML do

    it "converts xml tags into html" do
      converter = BookChef::Parser::XML2HTML.new("#@book_dir/merge_expected.xml")
      converter.run
      converter.save_to("#@book_dir/html_converted.html")

      converted_html = Nokogiri::XML.parse File.new("#@book_dir/html_converted.html")
      source_xml     = Nokogiri::XML.parse File.new("#@book_dir/html_expected.html")
      #File.unlink    "#{@book_dir}/html_converted.html"

      converted_html.should be_equivalent_to(source_xml)
    end

  end


end
