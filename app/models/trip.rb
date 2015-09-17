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

end
