Dir["#{File.dirname(__FILE__)}/ruby/*.rb"].sort.each do |path|
  require "metter/ext/ruby/#{File.basename(path, '.rb')}"
end
