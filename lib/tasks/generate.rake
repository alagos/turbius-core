require 'pry'

namespace :json_generate do

  desc 'Get a json file of current cities'
  task :cities => :environment do
    filename = 'cities.json'
    output = File.expand_path(
      File.join('..', 'turbius-static','source', 'data', filename)
    )
    city_extra = {type: 'bubble',color: '#6c00ff'}
    cities = City.with_coordinates.as_json.map{|json|
      json.merge(city_extra)
    }

    data_provider = {
      "map": "chileLow",
      "images": cities,
      "getAreasFromMap": true
    }
    File.write(output, data_provider.to_json)
  end
end
