require 'rails_helper'

RSpec.describe 'Users', type: :system do
  describe '#create' do
    it 'エラーメッセージ用の表示領域が描画されていること' do
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
