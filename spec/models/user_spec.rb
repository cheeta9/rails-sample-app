require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { FactoryBot.build(:user) }
  let!(:other_user) { FactoryBot.create(:other_user) }
  let!(:admin_user) { FactoryBot.create(:admin_user) }

  it 'userが有効であること' do
    expect(user).to be_valid
  end

  it 'nameが必須であること' do
    user.name = ''
    expect(user).not_to be_valid
  end

  it 'nameは50文字以内であること' do
    user.name = 'a' * 51
    expect(user).not_to be_valid
  end

  it 'emailが必須であること' do
    user.email = ''
    expect(user).not_to be_valid
  end

  it 'emailは255文字以内であること' do
    user.email = "#{'a' * 244}@example.com"
    expect(user).not_to be_valid
  end

  it 'emailが有効な形式であること' do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      user.email = valid_address
      expect(user).to be_valid
    end
  end

  it 'emailが無効な形式の場合は失敗すること' do
    invalid_addresses = %w[
      user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com
      foo@bar..com
    ]
    invalid_addresses.each do |invalid_address|
      user.email = invalid_address
      expect(user).not_to be_valid
    end
  end

  it 'emailは重複して登録できないこと' do
    duplicate_user = user.dup
    duplicate_user.email.upcase!
    user.save
    expect(duplicate_user).not_to be_valid
  end

  it 'emailは小文字でデータベースに登録されていること' do
    mixed_case_email = 'Foo@ExAPMle.CoM'
    user.email = mixed_case_email
    user.save
    expect(user.reload.email).to eq mixed_case_email.downcase
  end

  it 'passwordが必須であること' do
    user.password = user.password_confirmation = ' ' * 6
    expect(user).not_to be_valid
  end

  it 'passwordは6文字以上であること' do
    user.password = user.password_confirmation = 'a' * 5
    expect(user).not_to be_valid
  end

  describe '#authenticated?' do
    it 'digestがnilならfalseを返すこと' do
      expect(user.authenticated?(:remember, '')).to be_falsey
    end
  end

  describe '#follow and #unfollow' do
    before { user.save! }

    it 'followするとfollowing?がtrueになること' do
      expect(user.following?(other_user)).to be_falsy
      user.follow(other_user)
      expect(other_user.followers.include?(user)).to be_truthy
      expect(user.following?(other_user)).to be_truthy
    end

    it 'unfollowするとfollowing?がfalseになること' do
      user.follow(other_user)
      expect(other_user.followers.include?(user)).to be_truthy
      expect(user.following?(other_user)).to be_truthy
      user.unfollow(other_user)
      expect(user.following?(other_user)).to be_falsy
    end
  end

  describe '#feed' do
    before do
      10.times { FactoryBot.create(:micropost, user: user) }
      10.times { FactoryBot.create(:micropost, user: other_user) }
      10.times { FactoryBot.create(:micropost, user: admin_user) }
      user.follow(other_user)
    end

    it ' フォローしているユーザーの投稿が表示されること' do
      other_user.microposts.each do |micropost|
        expect(user.feed.include?(micropost)).to be_truthy
      end
    end

    it ' 自分の投稿が表示されること' do
      user.microposts.each do |micropost|
        expect(user.feed.include?(micropost)).to be_truthy
      end
    end

    it ' フォローしていないユーザーの投稿が表示されないこと' do
      admin_user.microposts.each do |micropost|
        expect(user.feed.include?(micropost)).to be_falsy
      end
    end
  end
end
