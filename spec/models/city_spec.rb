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

require 'rails_helper'

RSpec.describe City, type: :model do
  let(:city) { create(:city) }

  describe '#longitude' do
    it { expect(city.longitude).to eq(-10)}
  end

  describe '#latitude' do
    it { expect(city.latitude).to eq(20)}
  end

  describe '#as_json' do
    let(:city_json) { {
      "longitude": -10.0,
      "latitude": 20.0,
      "label":"Santiago"
    } }
    it { expect(city.as_json).to eq(city_json)}
  end
end
