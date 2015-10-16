class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.string :city
      t.string :full_address
      t.string :province
      t.st_point :lonlat, geographic: true

      t.timestamps null: false
    end
  end
end
