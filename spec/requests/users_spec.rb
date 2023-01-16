require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /signup' do
    it '正常にレスポンスを返すこと' do
      get signup_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include full_title('Sign up')
    end
  end

  describe 'POST /signup' do
    it '無効な値の場合は登録できないこと' do
      expect do
        post users_path, params: { user: { name: '',
                                           email: 'user@invalid',
                                           password: 'foo',
                                           password_confirmation: 'foobar' } }
      end.not_to change(User, :count)
    end

    context '有効な値の場合' do
      let!(:user_params) do
        { user: { name: 'Example User',
                  email: 'user@example.com',
                  password: 'password',
                  password_confirmation: 'password' } }
      end

      it '登録できること' do
        expect { post users_path, params: user_params }.to change(User, :count).by 1
        user = User.last
        expect(response).to redirect_to user
        expect(flash[:success]).not_to be_empty
        expect(logged_in?).to be_truthy
      end
    end
  end
end
