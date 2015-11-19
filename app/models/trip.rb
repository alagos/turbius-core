# == Schema Information
#
# Table name: trips
#
#  id          :integer          not null, primary key
#  origin      :string(255)
#  destination :string(255)
#  available   :boolean          default(TRUE)
#  created_at  :datetime
#  updated_at  :datetime
#

class Trip < ActiveRecord::Base
  has_many :itineraries

  scope :availables, -> { where(available: true) }
  scope :unavailables, -> { where(available: false) }
  scope :sorted, -> { order(:origin, :destination) }

  def set_unavailable
    self.update_attributes(available: false) if self.available?
  end

  def set_available
    self.update_attributes(available: true) unless self.available?
  end

  # # Helper methods to get specific trip by origin and destination
  # Settings.cities.permutation(2).each do |origin, destination|

  #   define_singleton_method "#{origin.parameterize.underscore}_to_#{destination.parameterize.underscore}" do
  #     find_by(origin: origin, destination: destination)
  #   end

  # end

  # Settings.cities.each do |city|

  #   define_singleton_method "from_#{city.parameterize.underscore}" do
  #     where(origin: city)
  #   end

  #   define_singleton_method "to_#{city.parameterize.underscore}" do
  #     where(destination: city)
  #   end

  # end

end
