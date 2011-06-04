['setup', 'client', 'worker'].each do |f|
  require(File.expand_path("../#{f}", __FILE__))
end
