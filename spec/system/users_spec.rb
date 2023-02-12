require 'rails_helper'

RSpec.describe 'Users', type: :system do
  describe '#index' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:admin_user) { FactoryBot.create(:admin_user) }

    before do
      30.times { FactoryBot.create(:index_user) }
      log_in(user)
      visit users_path
    end

    context 'adminユーザーでない場合' do
      before do
        log_in(user)
        visit users_path
      end

      it 'ページネーションが表示されること' do
        expect(page).to have_css '.pagination'
        expect(page.all('div.pagination').count).to eq 2
      end

      it 'ユーザーごとのリンクが存在すること' do
        User.order(:id).take(30).each do |user|
          expect(page).to have_link user.name
        end
      end

      it '削除リンクが表示されないこと' do
        expect(page).not_to have_link 'delete'
      end
    end

    context 'adminユーザーである場合' do
      before do
        log_in(admin_user)
        visit users_path
      end

      it 'ページネーションが表示されること' do
        expect(page).to have_css '.pagination'
        expect(page.all('div.pagination').count).to eq 2
      end

      it 'ユーザーごとのリンクが存在すること' do
        User.order(:id).take(30).each do |user|
          expect(page).to have_link user.name
        end
      end

      it '削除リンクが表示されること' do
        User.order(:id).take(30).each do |user|
          next if user == admin_user

          expect(page).to have_link 'delete', href: user_path(user)
        end
      end

      it '自分自身の削除リンクは表示されないこと' do
        expect(page).not_to have_link 'delete', href: user_path(admin_user)
      end
    end
  end

  describe '#create' do
    it 'エラーメッセージが表示されていること' do
      visit signup_path

      fill_in 'Name', with: ''
      fill_in 'Email', with: 'user@invalid'
      fill_in 'Password', with: 'foo'
      fill_in 'Confirmation', with: 'bar'
      click_button 'Create my account'

      expect(page).to have_content 'The form contains 4 errors.'
    end
  end

  describe '#following' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:other_user) { FactoryBot.create(:other_user) }

    before do
      user.follow(other_user)
      log_in user
    end

    it 'followingの数とフォローしているユーザーへのリンクが表示されること' do
      visit following_user_path(user)
      expect(page).to have_content '1 following'
      expect(page).to have_link other_user.name, href: user_path(other_user)
    end
  end

  describe '#followers' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:other_user) { FactoryBot.create(:other_user) }

    before do
      user.follow(other_user)
      log_in other_user
    end

    it 'followersの数とフォローしているユーザーへのリンクが表示されること' do
      visit followers_user_path(other_user)
      expect(page).to have_content '1 followers'
      expect(page).to have_link user.name, href: user_path(user)
    end
  end
end
