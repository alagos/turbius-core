# == Schema Information
#
# Table name: cities
#
#  id           :integer          not null, primary key
#  name         :string
#  city         :string
#  full_address :string
#  province     :string
#  lonlat       :geography({:srid point, 4326
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class City < ActiveRecord::Base

  alias_attribute :label, :name

  scope :with_coordinates, -> { where.not(lonlat: nil)}
  scope :without_coordinates, -> { where(lonlat: nil)}

  def longitude
    lonlat.lon if lonlat
  end

  def latitude
    lonlat.lat if lonlat
  end

  def as_json
    super(only: [], methods:[:longitude, :latitude, :label]).symbolize_keys
  end

end
