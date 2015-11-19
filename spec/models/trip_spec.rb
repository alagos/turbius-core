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

require 'rails_helper'

RSpec.describe Trip, :type => :model do
  let(:trip) { create(:trip) }

  context 'availability' do
    subject {trip.available}

    describe '#set_available' do
      before { trip.set_available }
      it { is_expected.to be true }
    end

    describe '#set_unavailable' do
      before { trip.set_unavailable }
      it { is_expected.to be false }
    end
  end

  describe '.availables' do
    it { expect(Trip.availables).to eq [trip] }
  end

  describe '.unavailables' do
    it { expect(Trip.unavailables).to be_empty }
  end

end
