
# '78.40.124.16 - - [01/Apr/2013:06:59:33 +0000] 
# "GET / HTTP/1.0" 200 25246 "-" 
# "Pingdom.com_bot_version_1.4_(http://www.pingdom.com)"'

require 'sqlite3'
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

	def parse_file
		@parsed_log = File.foreach(@file).map { |log_line| parse_line(log_line) }
	end

	attr_reader :parsed_log

end

class Database

	def initialize
		@db = SQLite3::Database.new("logs.db")
	
		exist = @db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='logs'")
		init_db if exist.empty?
	end

	def init_db
		@db.execute("CREATE TABLE logs (id integer PRIMARY KEY AUTOINCREMENT," +
		"ip varchar(20), time DATETIME, method varchar(50), path text(1000),"+
		"httpver varchar(50), code varchar(11), size varchar(50), user_agent text(500))")
	end

	def stats(type)
		query = @db.execute("SELECT #{type} FROM logs")
		query = query.flatten

		unique_items = query.uniq
		item_count = unique_items.map { |item| [item, query.count(item)] }
		item_count = Hash[item_count]  # Convert nested array pairs into hash
	end

	def unique_hits
		query = @db.execute("SELECT ip, time FROM logs")
		visited = []
		hits = 0

		query.each do |ip, time|
			next if visited.include? ip
			visited << ip

			t = Time.parse(time.sub(":", " "))

			if (t - Date.today.to_time) > 0
				hits += 1
			end

			# if (Time.now - t) < 10.day
			# 	hits += 1
			# end
		end
		
		return hits
	end

	def insert_data(data)
		@db.transaction # Begin transaction, else it will be very slow

		data.each do |log_line|
			next if log_line['ip'].nil?

			query = "INSERT INTO logs (ip, time, method, path, httpver, code, size, user_agent) VALUES(?, ?, ?, ?, ?, ?, ?, ?)"
			values = log_line['ip'],  log_line['time'], log_line['method'],  log_line['path'],  log_line['httpver'],  log_line['code'], log_line['size'],  log_line['user_agent']

			@db.execute(query, values)
		end

		@db.commit
	end

end
