class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.st_point :lonlat, geographic: true

      t.timestamps null: false
    end
  end
end
