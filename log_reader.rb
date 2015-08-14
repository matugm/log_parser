require 'uri'
require 'sinatra'

require_relative 'log_parser'
require_relative 'log_database'
require_relative 'output_filter'

db   = Database.new
data_types = %w( user_agent ip code path method referer )

before { @time = Time.now }

get '/' do
  redirect to('/path')
end

get '/code/:num' do
  data = db.get_code_data(params[:num])
  data = data.to_a.uniq

  erb :index, :locals => { stats: data, data_types: data_types, db: db, time: @time }
end

get '/:stats' do
  return "Invalid stat type" unless data_types.include? params[:stats]
  stats = db.stats(params[:stats])

  erb :index, :locals => { stats: stats, data_types: data_types, db: db, time: @time }
end
