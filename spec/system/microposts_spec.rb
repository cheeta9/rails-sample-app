require 'rails_helper'

RSpec.describe "Microposts", type: :system do
  let!(:user) { FactoryBot.create(:user) }
  let!(:post_count) { 35 }

  before do
    FactoryBot.create_list(:micropost, post_count, user: user)
    visit user_path user
  end

  describe 'StaticPages#home' do
    before do
      log_in user
      visit root_path
    end

    it '投稿数が正しく表示されていること' do
      expect(page).to have_content "#{post_count} microposts"

      user.microposts.destroy_all
      visit current_path
      expect(page).to have_content '0 microposts'

      fill_in 'micropost_content', with: 'Hellow world!!!'
      click_button 'Post'
      expect(page).to have_content '1 micropost'
    end

    it 'ページネーションが表示されること' do
      expect(page).to have_css '.pagination'
      expect(page.all('div.pagination').count).to eq 1
    end

    it '削除リンクが表示されていること' do
      expect(page).to have_link 'delete'

      fill_in 'micropost_content', with: 'Hellow world!!!'
      click_button 'Post'
      expect(page).to have_content 'Hellow world!!!'

      last_micropost = Micropost.first
      expect { click_link 'delete', href: micropost_path(last_micropost) }.to change(Micropost, :count).by(-1)

      expect(page).not_to have_content 'Hellow world!!!'
    end

    context '無効な送信の場合' do
      it 'contentが空の場合は投稿できないこと' do
        fill_in 'micropost_content', with: ''
        click_button 'Post'

        expect(page).to have_content 'The form contains 1 error.'
      end
    end

    context '有効な送信の場合' do
      it '投稿できること' do
        expect {
          fill_in 'micropost_content', with: 'test'
          click_button 'Post'
        }.to change(Micropost, :count).by(1)

        expect(page).to have_content 'test'
      end

      it '画像が添付できること' do
        expect do
          fill_in 'micropost_content', with: 'test'
          attach_file 'micropost[image]', "#{Rails.root}/spec/factories/kitten.jpg"
          click_button 'Post'
        end.to change(Micropost, :count).by(1)

        attached_micropost = Micropost.first
        expect(attached_micropost.image).to be_attached
      end
    end
  end

  describe 'Users#show' do
    before do
      log_in user
      visit root_path
    end

    it '30件表示されていること' do
      user.microposts.take(30).each do |micropost|
        expect(page).to have_content micropost.content
      end
      user.microposts.reverse.take(5).each do |micropost|
        expect(page).not_to have_content micropost.content
      end
    end

    it 'ページネーションが表示されること' do
      expect(page).to have_css '.pagination'
      expect(page.all('div.pagination').count).to eq 1
    end

    it '削除リンクが表示されていること' do
      expect(page).to have_link 'delete'

      fill_in 'micropost_content', with: 'Hellow world!!!'
      click_button 'Post'
      expect(page).to have_content 'Hellow world!!!'

      last_micropost = Micropost.first
      expect { click_link 'delete', href: micropost_path(last_micropost) }.to change(Micropost, :count).by(-1)

      expect(page).not_to have_content 'Hellow world!!!'
    end

    it '他人のプロフィール画面では削除リンクが表示されないこと' do
      other_user = FactoryBot.create(:other_user)
      visit user_path(other_user)
      expect(page).not_to have_link 'delete'
    end

    context '無効な送信の場合' do
      it 'contentが空の場合は投稿できないこと' do
        fill_in 'micropost_content', with: ''
        click_button 'Post'

        expect(page).to have_content 'The form contains 1 error.'
      end
    end

    context '有効な送信の場合' do
      it '投稿できること' do
        expect {
          fill_in 'micropost_content', with: 'test'
          click_button 'Post'
        }.to change(Micropost, :count).by(1)

        expect(page).to have_content 'test'
      end

      it '画像が添付できること' do
        expect do
          fill_in 'micropost_content', with: 'test'
          attach_file 'micropost[image]', "#{Rails.root}/spec/factories/kitten.jpg"
          click_button 'Post'
        end.to change(Micropost, :count).by(1)

        attached_micropost = Micropost.first
        expect(attached_micropost.image).to be_attached
      end
    end
  end
end
