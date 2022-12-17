require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /signup' do
    it '正常にレスポンスを返すこと' do
      get signup_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include full_title('Sign up')
    end
  end
end
