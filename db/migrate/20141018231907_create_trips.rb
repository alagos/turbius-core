class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string :origin
      t.string :destination
      t.boolean :available, default: true

      t.timestamps
    end
  end
end
