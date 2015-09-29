# == Schema Information
#
# Table name: trips
#
#  id          :integer          not null, primary key
#  origin      :string(255)
#  destination :string(255)
#  available   :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

class Trip < ActiveRecord::Base
  has_many :itineraries

  scope :availables, -> { where(available: true) }
  scope :unavailables, -> { where(available: false) }
  scope :sorted, -> { order(:origin, :destination) }

  def set_unavailable
    self.update_attributes(available: false)
  end

  # Helper methods to get specific trip by origin and destination
  Settings.cities.permutation(2).each do |origin, destination|

    define_singleton_method "#{origin.parameterize.underscore}_to_#{destination.parameterize.underscore}" do
      find_by(origin: origin, destination: destination)
    end

  end

end
