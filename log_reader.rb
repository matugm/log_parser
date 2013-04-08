
require_relative 'log_parser'
require 'sinatra'
require 'uri'

class String
	def filter?
		encoded = URI.encode(self)
		path = URI(encoded).path

		filter_paths = %w{ /wp-content /wp-admin /wp-includes }
		filter_paths.any? { |filter| 	path.start_with? filter }
	end
end

def escape_html(str)
	str = str.gsub("<","&lt;")
	str = str.gsub(">","&gt;")
	str = str.gsub("\"","&quot;")
	str = str.gsub("'", "&#39;")
end

get '/:stats' do
	time = Time.now

	db = Database.new
	stats = db.stats(params[:stats])

	data_types = %w{ user_agent ip code path method }

	output = %q{
	<style type="text/css" title="currentStyle">
			@import "demo_table.css";

			#demo {
				width: 40%;
				margin: auto;
			}

			#example {
				margin: 0 auto;
				clear: both;
			}

	</style>

	<script type="text/javascript" language="javascript" src="jquery.js"></script>
	<script type="text/javascript" language="javascript" src="jquery.dataTables.min.js"></script>
	<script type="text/javascript" charset="utf-8">
		$(document).ready(function() {
			$('#example').dataTable( {
				"aaSorting": [[ 1, "desc" ]]
			} );
		} );
	</script>
	}

	data_types.each do |type|
		output << "<a class='css3button' href='/#{type}'>#{type}</a>   "
	end
	
	output << %q{

	<br />
	<div id="demo">
	<table border=0 cellpadding=5 id="example">

	<thead>
		<tr>
			<th>Item</th>
			<th>Count</th>
		</tr>
	</thead>

	<tbody>
	
	}

	stats.each do |k, v|
		next if params[:stats] == "path" && k.filter?
		next if k.nil? || k.empty?
		output << "<tr><td>#{escape_html(k)}</td><td>#{escape_html(v)}</td>\n"
	end
	output << "</tbody></table></div>"

	output << "<br> Unique hits today: #{db.unique_hits}"
	output << "<br> Generated in: #{Time.now - time}"

	return output
end
