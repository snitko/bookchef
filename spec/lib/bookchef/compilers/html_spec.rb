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
    expected_html  = File.read("#@book_dir/html_expected.html").gsub('#{gem_path}', BookChef::LIB_PATH)
    expected_html  = Nokogiri::XML.parse expected_html
    File.unlink    "#{@book_dir}/html_converted.html"

    converted_html.should be_equivalent_to(expected_html)
  end

end
