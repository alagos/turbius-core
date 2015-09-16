class CreateItineraries < ActiveRecord::Migration
  def change
    create_table :itineraries do |t|
      t.datetime :arrival_date
      t.datetime :departure_date
      t.string :arrival_station
      t.string :departure_station
      t.string :seat_type
      t.integer :free_seats
      t.integer :total_seats
      t.integer :fare
      t.references :trip, index: true

      t.timestamps
    end
  end
end
