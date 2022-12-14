require 'rails_helper'

RSpec.describe 'Site layout', type: :system do
  describe 'layout links' do
    it 'root_pathへのリンクが2つ、help, about, contactへのリンクが表示されていること' do
      visit root_path

      link_to_root = page.find_all("a[href=\"#{root_path}\"]")
      expect(link_to_root.size).to eq 2
      expect(page).to have_link 'Help', href: help_path
      expect(page).to have_link 'About', href: about_path
      expect(page).to have_link 'Contact', href: contact_path
    end
  end
end