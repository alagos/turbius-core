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

class Itinerary < ActiveRecord::Base
  has_paper_trail

  belongs_to :trip

  scope :seat_types, -> { select(:seat_type).uniq }

  def self.params_by_dom(dom)
    temp_itinerary = dom.children
    {
      arrival_date: get_date_time(temp_itinerary[4], temp_itinerary[5]),
      departure_date: get_date_time(temp_itinerary[0], temp_itinerary[1]),
      arrival_station: temp_itinerary[3].content,
      departure_station: temp_itinerary[2].content,
      seat_type: temp_itinerary[7].content,
      fare: temp_itinerary[6].content.gsub(/\D/,'').to_i
    }
  end

  def self.find_same_itinerary(params)
    find_by(
      departure_date: params[:departure_date],
      arrival_date: params[:arrival_date],
      seat_type: params[:seat_type]
    )
  end

  def busy_seats
    total_seats - free_seats if total_seats && free_seats
  end

  def departure_time
    departure_date.strftime('%H:%M')
  end

  def arrival_time
    arrival_date.strftime('%H:%M')
  end

  def price
    ActionController::Base.helpers.number_to_currency(fare, precision: 0)
  end

  private

  def self.get_date_time(date, time)
    DateTime.strptime(
      "#{date.content} #{time.content} #{Time.now.getlocal.zone}",'%d/%m/%Y %H:%M %Z'
    )
  end
end
