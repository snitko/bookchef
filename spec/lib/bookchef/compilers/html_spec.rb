require "spec_helper"
require "equivalent-xml"

describe BookChef::Compiler::HTML do

  before(:each) do
    @book_dir = File.dirname(__FILE__) + '/../../../fixtures/book'
  end

  it "converts xml tags into html" do
    converter = BookChef::Compiler::HTML.new("#@book_dir/merge_expected.xml")
    converter.run
    converter.save_to("#@book_dir/html_converted.html")

    converted_html = Nokogiri::XML.parse File.new("#@book_dir/html_converted.html")
    source_xml     = Nokogiri::XML.parse File.new("#@book_dir/html_expected.html")
    File.unlink    "#{@book_dir}/html_converted.html"

    converted_html.should be_equivalent_to(source_xml)
  end

end
