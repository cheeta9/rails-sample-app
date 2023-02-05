require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let!(:user) {FactoryBot.create(:user) }
  let!(:micropost) { FactoryBot.build(:micropost, user: user) }

  it 'micropostが有効であること' do
    expect(micropost).to be_valid
  end

  it 'user_idが必須であること' do
    micropost.user_id = nil
    expect(micropost).not_to be_valid
  end

  it 'contentが必須であること' do
    micropost.content = nil
    expect(micropost).not_to be_valid
  end

  it 'contentが140文字以内であること' do
    micropost.content = 'a' * 139
    expect(micropost).to be_valid

    micropost.content = 'a' * 140
    expect(micropost).to be_valid

    micropost.content = 'a' * 141
    expect(micropost).not_to be_valid
  end

  it '並び順が投稿の新しい順になっていること' do
    micropost.save!
    most_recent_micropost = FactoryBot.create(:most_recent_micropost, user: user)
    expect(Micropost.first).to eq most_recent_micropost
  end

  it 'ユーザーが削除された場合は一緒に削除されること' do
    micropost.save!
    expect { user.destroy }.to change(Micropost, :count).by(-1)
  end
end
