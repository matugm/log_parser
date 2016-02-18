require_relative '../log_parser'
require_relative '../log_database'

describe 'LogParser' do
  before(:all) do
    @parser = LogParser.new "/tmp/access.log"
    @data = [{ "ip"=> '1.1.1.1', "time"=>'01/Apr/2020:06:59:33 +0000', "method"=>'get', "path"=>'/', "httpver"=>nil, "code"=> 200, "size"=> 1200, "referer"=>nil, "user_agent"=> 'Firefox' }]
  end

  it "should initialize the database" do
    file = "logs.db"
    File.delete(file)
    Database.new
    File.exist?(file).should == true
  end

  it "should insert and return data" do
    db = Database.new
    db.insert_data(@data)
    db.stats("user_agent").size.should > 0
  end

  it "should count unique hits" do
    db = Database.new
    db.unique_hits.should > 0
  end
end
