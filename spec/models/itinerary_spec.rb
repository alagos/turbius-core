# == Schema Information
#
# Table name: itineraries
#
#  id                :integer          not null, primary key
#  arrival_date      :datetime
#  departure_date    :datetime
#  arrival_station   :string(255)
#  departure_station :string(255)
#  seat_type         :string(255)
#  free_seats        :integer
#  total_seats       :integer
#  fare              :integer
#  trip_id           :integer
#  created_at        :datetime
#  updated_at        :datetime
#

require 'rails_helper'

RSpec.describe Itinerary, :type => :model do
  let(:itinerary) { create(:itinerary) }
  let(:another_itinerary) { create(:another_itinerary) }
  let(:itinerary_dom) { Nokogiri::HTML(File.open("spec/mocks/itinerary.html", "r")) }

  describe '.params_by_dom' do

    it 'returns parameters to create an itinerary from a dom' do
      expect(Itinerary.params_by_dom(itinerary_dom)).to eq(attributes_for(:itinerary))
    end
  end

  describe '.find_same_itinerary' do

    it 'returns an itinerary for the given seat type, arrival and departure dates' do
      expect(Itinerary.find_same_itinerary(attributes_for(:itinerary))).to include itinerary
    end

    it 'does not returns an itinerary for the given seat type, arrival and departure dates' do
      expect(Itinerary.find_same_itinerary(attributes_for(:another_itinerary))).not_to include itinerary
    end
  end

  describe '#busy_seats' do

    let(:itinerary_without_seats) {build(:itinerary_without_seats)}

    it 'returns how many seats are available' do
      expect(itinerary.busy_seats).to be(6)
    end

    it 'returns nil if there are no seats' do
      expect(itinerary_without_seats.busy_seats).to be_nil
      itinerary_without_seats.total_seats = 10
      expect(itinerary_without_seats.busy_seats).to be_nil
    end
  end
end
