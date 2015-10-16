class City < ActiveRecord::Base

  def longitude
    lonlat.lon if lonlat
  end

  def latitude
    lonlat.lat if lonlat
  end

end
