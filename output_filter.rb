class String
  def filter?
    encoded = URI.encode(self)
    path 	  = URI(encoded).path

    filter_paths = %w{ /wp-content /wp-admin /wp-includes }
    filter_paths.any? { |filter| path.start_with? filter }
  end
end

def escape_html(str)
  str = str.gsub("<","&lt;")
  str = str.gsub(">","&gt;")
  str = str.gsub("\"","&quot;")
  str = str.gsub("'", "&#39;")
end
