
require_relative 'log_parser'
require_relative 'log_database'

file = "/tmp/access.log"
pointer = 0

if (File.exist? "file_pointer")
	File.open("file_pointer","r") { |file| pointer = file.read }
end

@parser = LogParser.new(file)
new_position = @parser.parse_file(pointer.to_i)
data = @parser.parsed_log

db = Database.new
db.insert_data(data)

puts "Database updated... #{data.size} new records."

File.open("file_pointer", "w") { |file| file.write new_position  }

# 2. Guardar los hits unicos diarios de todo el mes.