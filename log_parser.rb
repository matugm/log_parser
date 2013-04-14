
# '78.40.124.16 - - [01/Apr/2013:06:59:33 +0000] 
# "GET / HTTP/1.0" 200 25246 "-" 
# "Pingdom.com_bot_version_1.4_(http://www.pingdom.com)"'

require 'date'
require 'time'

class Fixnum
   SECONDS_IN_DAY = 24 * 60 * 60
   def day
     self * SECONDS_IN_DAY
   end
   def ago
     Time.now - self
   end
end

class LogParser

	def initialize(file)
		@file = file
		@parsed_log = []
	end

	def parse_line(log_line)
		log_parts = {}
		log_line = log_line.split(/^(\S+) \S+ \S+ \[([^\]]+)\] "([A-Z]+) (\/\S*) ([^"]*)" (\d+) (\d+) "(?:[^"]*)" "([^"]*)"$/)

		if log_line != nil
			log_parts['ip'] = log_line[1]
			log_parts['time'] = log_line[2]
			log_parts['method'] = log_line[3]
			log_parts['path'] = log_line[4]
			log_parts['httpver'] = log_line[5]
			log_parts['code'] = log_line[6]
			log_parts['size'] = log_line[7]
			log_parts['user_agent'] = log_line[8]
		end

		return log_parts
	end

	def parse_file(pointer = 0)
		 File.open(@file) do |file|
		 	file.pos = pointer
		 	@parsed_log = file.map { |log_line| parse_line(log_line) }
		 	
		 	return file.pos
		 end
	end

	attr_reader :parsed_log

end
