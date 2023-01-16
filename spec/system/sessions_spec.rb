require 'rails_helper'

RSpec.describe 'Sessions', type: :system do
  describe '#create' do
    let!(:user) { FactoryBot.create(:user) }

    context '無効な値の場合' do
      it 'エラーメッセージが表示されること' do
        visit login_path

        fill_in 'Email', with: ''
        fill_in 'Password', with: ''
        click_button 'Log in'

        expect(page).to have_content 'Invalid email/password combination'

        visit root_path
        expect(page).not_to have_content 'Invalid email/password combination'
      end
    end

    context 'ユーザー情報と一致しない値の場合' do
      it 'エラーメッセージが表示されること' do
        visit login_path

        fill_in 'Email', with: user.email
        fill_in 'Password', with: 'hogefuga'
        click_button 'Log in'

        expect(page).to have_content 'Invalid email/password combination'

        visit root_path
        expect(page).not_to have_content 'Invalid email/password combination'
      end
    end

    context '有効な値の場合' do
      it 'ログインユーザー用のページが表示されること' do
        visit login_path

        fill_in 'Email', with: user.email
        fill_in 'Password', with: user.password
        click_button 'Log in'

        expect(page).not_to have_selector "a[href=\"#{login_path}\"]"
        expect(page).to have_selector "a[href=\"#{logout_path}\"]"
        expect(page).to have_selector "a[href=\"#{user_path(user)}\"]"
      end
    end
  end

  describe '#destroy' do
    let!(:user) { FactoryBot.create(:user) }

    it 'ログアウトできること' do
      visit login_path

      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_button 'Log in'

      expect(page).not_to have_selector "a[href=\"#{login_path}\"]"
      expect(page).to have_selector "a[href=\"#{logout_path}\"]"
      expect(page).to have_selector "a[href=\"#{user_path(user)}\"]"

      click_link 'Log out'

      expect(page).to have_selector "a[href=\"#{login_path}\"]"
      expect(page).not_to have_selector "a[href=\"#{logout_path}\"]"
    end
  end
end
