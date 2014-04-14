Dir["#{File.dirname(__FILE__)}/rails/*.rb"].sort.each do |path|
  require "metter/ext/rails/#{File.basename(path, '.rb')}"
end
