require "spec_helper"

describe BookChef::Compiler::HTML do

  before(:each) do
    @book_dir = File.expand_path(File.dirname(__FILE__) + '/../../../fixtures/book')
  end

  it "converts xml tags into html" do
    source_xml = File.read("#@book_dir/merge_expected.xml").gsub('#{source_path}', "file://#@book_dir")
    source_xml.gsub!("<book>", "<book version=\"1.0.0\">")
    converter  = BookChef::Compiler::HTML.new(source_xml)
    converter.run
    converter.save_to("#@book_dir/html_converted.html")

    converted_html = File.read("#@book_dir/html_converted.html")
    expected_html  = File.read("#@book_dir/html_expected.html").gsub('#{gem_path}', BookChef::LIB_PATH).gsub('#{source_path}', "file://#@book_dir")

    File.unlink    "#{@book_dir}/html_converted.html"

    converted_html.should == expected_html
  end

end
