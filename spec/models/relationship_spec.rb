require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let!(:relationship) { FactoryBot.create(:relationship) }

  it 'relationshipが有効であること' do
    expect(relationship).to be_valid
  end

  it 'follower_idが必須でること' do
    relationship.follower = nil
    expect(relationship).not_to be_valid
  end

  it 'followed_idが必須でること' do
    relationship.followed = nil
    expect(relationship).not_to be_valid
  end
end
