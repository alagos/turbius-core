require 'pry'

namespace :json_generate do

  desc 'Get a json file of current cities'
  task :cities => :environment do
    filename = 'tmp/cities.json'
    Dir.mkdir('tmp') unless File.exists?('tmp')
    output = File.expand_path(File.join(filename))
    File.write(output, City.all.as_json)
  end
end
