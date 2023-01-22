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
end
