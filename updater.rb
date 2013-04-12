
require_relative 'log_parser'
require_relative 'log_database'

file = "/tmp/access.log"

@parser = LogParser.new(file)
data = @parser.parse_file

db = Database.new
db.insert_data(data)

puts "Database updated"
