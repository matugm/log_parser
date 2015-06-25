
require_relative 'log_parser'
require_relative 'log_database'
require 'sinatra'
require 'uri'

class String
  def filter?
    encoded = URI.encode(self)
    path = URI(encoded).path

    filter_paths = %w{ /wp-content /wp-admin /wp-includes }
    filter_paths.any? { |filter|   path.start_with? filter }
  end
end

def escape_html(str)
  str = str.gsub("<","&lt;")
  str = str.gsub(">","&gt;")
  str = str.gsub("\"","&quot;")
  str = str.gsub("'", "&#39;")
end

db = Database.new
time = Time.now
data_types = %w{ user_agent ip code path method referer }

get '/' do
  redirect to('/path')
end

get '/code/:num' do
  data = db.get_code_data(params[:num])
  data = data.to_a.uniq

  erb :index, :locals => { :stats => data, :data_types => data_types, :db => db, :time => time }
end

get '/:stats' do
  return "Invalid stat type" unless data_types.include? params[:stats]
  stats = db.stats(params[:stats])

  erb :index, :locals => { :stats => stats, :data_types => data_types, :db => db, :time => time }
end
