require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  describe 'GET /login' do
    it '正常にレスポンスを返すこと' do
      get login_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /login' do
    describe 'remember me' do
      it 'ONの場合はcookies[:remember_token]が空でないこと' do
        post login_path, params: { session: { email: user.email,
                                              password: user.password,
                                              remember_me: 1 } }
        expect(cookies[:remember_token]).not_to be_blank
        expect(cookies[:remember_token]).to eq controller.instance_variable_get('@user').remember_token
      end

      it 'OFFの場合はcookies[:remember_token]が空であること' do
        post login_path, params: { session: { email: user.email,
                                              password: user.password,
                                              remember_me: 0 } }
        expect(cookies[:remember_token]).to be_blank
      end
    end
  end

  describe 'DELETE /logout' do
    before do
      post login_path, params: { session: { email: user.email,
                                            password: user.password } }
    end

    it 'ログアウトできること' do
      expect(logged_in?).to be_truthy

      delete logout_path
      expect(logged_in?).to be_falsey
    end

    it '2回連続でログアウトしてもエラーにならないこと' do
      delete logout_path
      delete logout_path
      expect(response).to redirect_to root_path
    end
  end
end
