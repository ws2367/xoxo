# == Schema Information
#
# Table name: institutions
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  location_id :integer
#

require 'test_helper'

class InstitutionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end