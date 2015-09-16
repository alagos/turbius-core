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
    arrival_date "2014-10-16 00:40:00"
    departure_date "2014-10-16 05:35:00"
    arrival_station "Term.Maria Teresa"
    departure_station "TER.ALAMEDA TUR-BUS"
    seat_type "Semi Cama"
    free_seats 4
    total_seats 10
    fare 6_400
    trip nil

    factory :itinerary_without_seats do
      free_seats nil
      total_seats nil
    end
  end

  factory :another_itinerary, class: Itinerary do
    arrival_date "2014-10-19 10:40:00"
    departure_date "2014-10-19 09:00:00"
    arrival_station "TER.ALAMEDA TUR-BUS"
    departure_station "Algarrobo Terminal"
    seat_type "Salon Cama"
    free_seats 2
    total_seats 30
    fare 5_000

  end
end
