require 'rails_helper'

RSpec.describe 'StaticPages', type: :system do
  describe 'home' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:other_user) { FactoryBot.create(:other_user) }

    it 'root_pathへのリンクが2つ、help, about, contactへのリンクが表示されていること' do
      visit root_path

      link_to_root = page.find_all("a[href=\"#{root_path}\"]")
      expect(link_to_root.size).to eq 2
      expect(page).to have_link 'About', href: about_path
      expect(page).to have_link 'Contact', href: contact_path
      expect(page).to have_link 'Help', href: help_path
      expect(page).to have_link 'Sign up', href: signup_path
    end

    it 'followingとfollowersが正しく表示されていること' do
      log_in(user)
      visit root_path
      expect(page).to have_content '0 following'
      expect(page).to have_content '0 followers'

      user.follow(other_user)
      visit root_path
      expect(page).to have_content '1 following'
      expect(page).to have_content '0 followers'

      visit user_path(other_user)
      expect(page).to have_content '0 following'
      expect(page).to have_content '1 followers'

      user.unfollow(other_user)
      visit root_path
      expect(page).to have_content '0 following'
      expect(page).to have_content '0 followers'
    end

    it 'feedが正しく表示されること' do
      log_in(user)
      10.times { FactoryBot.create(:micropost, user: user) }
      10.times { FactoryBot.create(:micropost, user: other_user) }
      visit root_path
      user.microposts.each do |micropost|
        expect(page).to have_content micropost.content
      end
      other_user.microposts.each do |micropost|
        expect(page).not_to have_content micropost.content
      end

      user.follow(other_user)
      visit root_path
      user.microposts.each do |micropost|
        expect(page).to have_content micropost.content
      end
      other_user.microposts.each do |micropost|
        expect(page).to have_content micropost.content
      end
    end
  end
end
