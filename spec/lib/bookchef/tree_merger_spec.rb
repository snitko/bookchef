require "spec_helper"
require "equivalent-xml"

describe BookChef::TreeMerger do

  before(:each) do
    @book_dir = File.expand_path(File.dirname(__FILE__) + '/../../fixtures/book')
  end

  it "follows src= args in tags and merges files into one" do
    merger   = BookChef::TreeMerger.new(@book_dir, "main.xml")
    merger.run
    merger.save_to "#{@book_dir}/merge_saved.xml"
    
    merge_saved    = Nokogiri::XML.parse File.new("#{@book_dir}/merge_saved.xml")
    merge_expected = Nokogiri::XML.parse(File.read("#{@book_dir}/merge_expected.xml").gsub('#{source_path}', "file://#@book_dir"))
    File.unlink      "#{@book_dir}/merge_saved.xml"

    merge_saved.should be_equivalent_to(merge_expected)
  end


end
