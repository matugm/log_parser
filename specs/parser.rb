require_relative '../log_parser'

describe 'LogParser' do

  before(:all) do
    @parser = LogParser.new "/tmp/access.log"
    @test_line = '78.40.124.16 - - [01/Apr/2013:06:59:33 +0000] "GET / HTTP/1.0" 200 25246 "-" "Pingdom.com_bot_version_1.4_(http://www.pingdom.com)"'
  end

  it "Should have the correct number of lines" do
    results = @parser.parse_file(0)
    results.should > 10
  end

  it "should parse the IP correctly" do
    results = @parser.parse_line(@test_line)
    results['ip'].should == "78.40.124.16"
  end

  it "should parse the time of the request" do
    results = @parser.parse_line(@test_line)
    results['time'].should == "01/Apr/2013:06:59:33 +0000"
  end

  it "should parse the request method" do
    results = @parser.parse_line(@test_line)
    results['method'].should == "GET"
  end

  it "should parse the request path" do
    results = @parser.parse_line(@test_line)
    results['path'].should == "/"
  end

  it "should parse the http version" do
    results = @parser.parse_line(@test_line)
    results['httpver'].should == "HTTP/1.0"
  end

  it "should parse the response code" do
    results = @parser.parse_line(@test_line)
    results['code'].should == "200"
  end

  it "should parse the response size" do
    results = @parser.parse_line(@test_line)
    results['size'].should == "25246"
  end

  it "should parse the user agent" do
    results = @parser.parse_line(@test_line)
    results['user_agent'].should == "Pingdom.com_bot_version_1.4_(http://www.pingdom.com)"
  end
end
