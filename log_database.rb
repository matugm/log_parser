
require 'sqlite3'


class Database

	def initialize
		@db = SQLite3::Database.new("logs.db")
	
		exist = @db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='logs'")
		init_db if exist.empty?
	end

	def init_db
		@db.execute("CREATE TABLE logs (id integer PRIMARY KEY AUTOINCREMENT," +
		"ip varchar(20), time DATETIME, method varchar(50), path text(500)," +
		"httpver varchar(50), code varchar(11), size varchar(50),referer text(500)," +
		"user_agent text(500))")
	end

	def stats(type)
		query = @db.execute("SELECT #{type}, count(*) FROM logs GROUP BY #{type}")
		item_count = Hash[query]  # Convert nested array pairs into hash
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
			
		end
		
		return hits
	end

	def get_code_data(code)
		@db.query("SELECT path from logs WHERE code = ?", code)
	end

	def insert_data(data)
		@db.transaction # Begin transaction, else it will be very slow

		data.each do |log_line|
			next if log_line['ip'].nil?

			query = "INSERT INTO logs (ip, time, method, path, httpver, code, size, referer, user_agent) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)"
			fields = %w{ ip time method path httpver code size referer user_agent }
			values = fields.map	{ |field| log_line[field] }

			@db.execute(query, values)
		end

		@db.commit
	end

end
