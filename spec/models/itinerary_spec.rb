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
  let!(:itinerary) { create(:itinerary) }

  describe '.params_by_dom' do
    let(:itinerary_dom) { Nokogiri::HTML(File.open("spec/mocks/itinerary.html", "r")) }

    it 'returns parameters to create an itinerary from a dom' do
      expect(Itinerary.params_by_dom(itinerary_dom.css('tr')[0])).to eq(attributes_for(:itinerary))
    end
  end

  describe '.find_same_itinerary' do

    subject { Itinerary.find_same_itinerary(attributes_for(:itinerary)) }

    it { is_expected.to eq itinerary}

  end

  describe '#busy_seats' do

    it 'returns how many seats are available' do
      expect(itinerary.busy_seats).to be_nil
      itinerary.total_seats = 10
      expect(itinerary.busy_seats).to be_nil
      itinerary.free_seats = 4
      expect(itinerary.busy_seats).to be(6)
    end
  end

  describe '#departure_date_time' do
    it { expect(itinerary.departure_date_time).to eq "16/10 00:40"}
  end

  describe '#price' do
    it { expect(itinerary.price).to eq "$6,400"}
  end

end
