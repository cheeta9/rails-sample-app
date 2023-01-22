require 'rails_helper'

RSpec.describe 'StaticPages', type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:base_title) { 'Ruby on Rails Tutorial Sample App' }

  describe 'GET /' do
    context 'ログインしていない場合' do
      it '正常にレスポンスを返すこと' do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include base_title
      end
    end

    context 'ログインしている場合' do
      it '正常にレスポンスを返すこと' do
        log_in(user)
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include base_title
      end
    end
  end

  describe 'GET /help' do
    context 'ログインしていない場合' do
      it '正常にレスポンスを返すこと' do
        get help_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include full_title('Help')
      end
    end

    context 'ログインしている場合' do
      it '正常にレスポンスを返すこと' do
        log_in(user)
        get help_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include full_title('Help')
      end
    end
  end

  describe 'GET /about' do
    context 'ログインしてない場合' do
      it 'ログインページにリダイレクトすること' do
        get about_path
        expect(response).to redirect_to login_path
      end
    end

    context 'ログインしている場合' do
      it '正常にレスポンスを返すこと' do
        log_in(user)
        get about_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include full_title('About')
      end
    end
  end

  describe 'GET /contact' do
    context 'ログインしてない場合' do
      it 'ログインページにリダイレクトすること' do
        get contact_path
        expect(response).to redirect_to login_path
      end
    end

    context 'ログインしている場合' do
      it '正常にレスポンスを返すこと' do
        log_in(user)
        get contact_path
        assert_response :success
        expect(response.body).to include full_title('Contact')
      end
    end
  end
end
