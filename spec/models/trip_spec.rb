# == Schema Information
#
# Table name: trips
#
#  id          :integer          not null, primary key
#  origin      :string(255)
#  destination :string(255)
#  available   :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe Trip, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
