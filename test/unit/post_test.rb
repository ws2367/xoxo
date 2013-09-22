# == Schema Information
#
# Table name: posts
#
#  id           :integer          not null, primary key
#  content      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  entity_id    :integer
#  user_id      :integer
#  status       :boolean          default(TRUE)
#  followersNum :integer          default(0)
#  hatersNum    :integer          default(0)
#  likersNum    :integer          default(0)
#  viewersNum   :integer          default(0)
#

require 'test_helper'

class PostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end