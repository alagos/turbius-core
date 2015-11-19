ActiveAdmin.register City do
  config.sort_order = 'name_asc'

  index do
    selectable_column
    column :name
    column :city
    column :full_address
    column :province
    column :longitude
    column :latitude
    actions
  end

end
