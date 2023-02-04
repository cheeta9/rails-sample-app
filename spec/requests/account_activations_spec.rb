require 'rails_helper'

RSpec.describe "AccountActivations", type: :request do
  describe 'GET /account_activations/{id}/edit' do
    before do
      post users_path, params: { user: { name: 'Example User',
                                         email: 'user@example.com',
                                         password: 'password',
                                         password_confirmation: 'password' } }
      @user = controller.instance_variable_get('@user')
    end

    context '有効化トークンとemailが有効な場合' do
      before { get edit_account_activation_path(@user.activation_token, email: @user.email) }
      it '有効化されること' do
        @user.reload
        expect(@user).to be_activated
      end

      it 'ログイン状態になること' do
        expect(logged_in?).to be_truthy
      end

      it 'ユーザー詳細画面にリダイレクトすること' do
        expect(response).to redirect_to @user
      end
    end

    context '有効化トークンとemailが無効な場合' do
      it '有効化トークンが不正ならログイン状態にならないこと' do
        get edit_account_activation_path('invalid token', email: @user.email)
        expect(logged_in?).to be_falsy
      end

      it 'メールアドレスが不正ならログイン状態にならないこと' do
        get edit_account_activation_path(@user.activation_token, email: 'invalid')
        expect(logged_in?).to be_falsy
      end
    end
  end
end
