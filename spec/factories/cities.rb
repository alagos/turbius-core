# == Schema Information
#
# Table name: cities
#
#  id           :integer          not null, primary key
#  name         :string
#  city         :string
#  full_address :string
#  province     :string
#  lonlat       :geography({:srid point, 4326
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :city do
    name "MyString"
lonlat "MyString"
  end

end
