require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  let!(:base_title) { 'Ruby on Rails Tutorial Sample App' }

  describe 'GET /' do
    it 'returns http success' do
      get root_path
      expect(response).to have_http_status(:success)
      assert_select 'title', base_title
    end
  end

  describe 'GET /help' do
    it 'returns http success' do
      get help_path
      expect(response).to have_http_status(:success)
      assert_select 'title', "Help | #{base_title}"
    end
  end

  describe 'GET /about' do
    it 'returns http success' do
      get about_path
      expect(response).to have_http_status(:success)
      assert_select 'title', "About | #{base_title}"
    end
  end

  describe 'GET /contact' do
    it 'returns http success' do
      get contact_path
      assert_response :success
      assert_select 'title', "Contact | #{base_title}"
    end
  end
end
