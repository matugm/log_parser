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
		log_line = log_line.split(/^(\S+) \S+ \S+ \[([^\]]+)\] "([A-Z]+) (\/\S*) ([^"]*)" (\d+) (\d+) "([^"]*)" "([^"]*)"$/)

		if log_line
			fields = %w{ ip time method path httpver code size referer user_agent }
			fields.each_with_index { |field, count| log_parts[field] = log_line[count+1] }
		end

		return log_parts
	end

	def parse_file(pointer)
		File.open(@file) do |file|
			pointer = 0 if file.size < pointer
			file.pos = pointer

			@parsed_log = file.map { |log_line| parse_line(log_line) }
			return file.pos
		end
	end

	attr_reader :parsed_log

end
