require_relative '../log_parser'
require_relative '../log_database'

describe 'LogParser' do
  before(:all) do
    @parser = LogParser.new "/tmp/access.log"
  end

  it "should initialize the database" do
    file = "logs.db"
    File.delete(file)
    Database.new
    File.exist?(file).should == true
  end

  it "should insert and return data" do
    @parser.parse_file(0)
    db = Database.new
    db.insert_data(@parser.parsed_log)
    db.stats("user_agent").size.should > 0
  end

  it "should count unique hits" do
    db = Database.new
    db.unique_hits.should > 1
  end
end
