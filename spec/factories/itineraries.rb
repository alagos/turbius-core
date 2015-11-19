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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :itinerary do
    arrival_date DateTime.new(2014,10,16,5,35,0,'-3')
    departure_date DateTime.new(2014,10,16,0,40,0,'-3')
    departure_station "Term.Maria Teresa"
    arrival_station "TER.ALAMEDA TUR-BUS"
    seat_type "Semi Cama"
    fare 6_400

    trait :with_seats do
      free_seats 4
      total_seats 10
    end
  end

  factory :another_itinerary, class: Itinerary do
    arrival_date DateTime.new(2014,10,19,10,40,0,'-4')
    departure_date DateTime.new(2014,10,19,9,0,0,'-4')
    arrival_station "TER.ALAMEDA TUR-BUS"
    departure_station "Algarrobo Terminal"
    seat_type "Salon Cama"
    free_seats 2
    total_seats 30
    fare 5_000

  end
end
