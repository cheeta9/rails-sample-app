require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  let!(:base_title) { 'Ruby on Rails Tutorial Sample App' }

  describe 'GET /' do
    it '正常にレスポンスを返すこと' do
      get root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include base_title
    end
  end

  describe 'GET /help' do
    it '正常にレスポンスを返すこと' do
      get help_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include full_title('Help')
    end
  end

  describe 'GET /about' do
    it '正常にレスポンスを返すこと' do
      get about_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include full_title('About')
    end
  end

  describe 'GET /contact' do
    it '正常にレスポンスを返すこと' do
      get contact_path
      assert_response :success
      expect(response.body).to include full_title('Contact')
    end
  end
end
