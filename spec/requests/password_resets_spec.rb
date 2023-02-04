require 'rails_helper'

RSpec.describe 'PasswordResets', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  before { ActionMailer::Base.deliveries.clear }

  describe 'GET /password_reset/new' do
    it 'email用のinputタグが表示されていること' do
      get new_password_reset_path
      expect(response.body).to include 'name="password_reset[email]"'
    end
  end

  describe 'POST /password_resets' do
    it '無効なメールアドレスならflashが存在すること' do
      post password_resets_path, params: { password_reset: { email: '' } }
      expect(flash[:danger]).not_to be_empty
    end

    context '有効なメールアドレスの場合' do
      it 'reset_digestが変わっていること' do
        post password_resets_path, params: { password_reset: { email: user.email } }
        expect(user.reset_digest).not_to eq user.reload.reset_digest
      end

      it '送信メールが1件増えること' do
        expect do
          post password_resets_path, params: { password_reset: { email: user.email } }
        end.to change(ActionMailer::Base.deliveries, :count).by(1)
      end

      it 'flashが存在すること' do
        post password_resets_path, params: { password_reset: { email: user.email } }
        expect(flash[:info]).not_to be_empty
      end

      it 'rootページにリダイレクトすること' do
        post password_resets_path, params: { password_reset: { email: user.email } }
        expect(response).to redirect_to root_url
      end
    end
  end

  describe 'GET /password_reset/{id}/edit' do
    before do
      post password_resets_path, params: { password_reset: { email: user.email } }
      @user = controller.instance_variable_get('@user')
    end

    it 'トークンもメールアドレスも有効なら隠しフィールドにメールアドレスが表示されること' do
      get edit_password_reset_path(@user.reset_token, email: @user.email)
      expect(response.body).to include "<input type=\"hidden\" name=\"email\" id=\"email\" value=\"#{@user.email}\""
    end

    it 'メールアドレスが誤っている場合はrootページにリダイレクトすること' do
      get edit_password_reset_path(@user.reset_token, email: '')
      expect(response).to redirect_to root_url
    end

    it '無効なユーザーの場合はrootページにリダイレクトすること' do
      @user.toggle!(:activated)
      get edit_password_reset_path(@user.reset_token, email: @user.email)
      expect(response).to redirect_to root_url
    end

    it '無効なトークンの場合はrootページにリダイレクトすること' do
      get edit_password_reset_path('wrong token', email: @user.email)
      expect(response).to redirect_to root_url
    end

    it '有効期限切れのトークンの場合はnewページにリダイレクトすること' do
      @user.update_attribute(:reset_sent_at, 3.hours.ago)
      get edit_password_reset_path(@user.reset_token, email: @user.email)
      expect(response).to redirect_to new_password_reset_url
    end
  end

  describe 'PATCH /password_resets' do
    before do
      post password_resets_path, params: { password_reset: { email: user.email } }
      @user = controller.instance_variable_get('@user')
    end

    context '有効期限切れのトークンの場合' do
      before { @user.update_attribute(:reset_sent_at, 3.hours.ago) }

      it 'newページにリダイレクトすること' do
        patch password_reset_path(@user.reset_token), params: { email: @user.email,
                                                                user: { password: 'hogehoge',
                                                                        password_confirmation: 'hogehoge' } }
        expect(response).to redirect_to new_password_reset_url
      end

      it 'エラーメッセージが表示されること' do
        patch password_reset_path(@user.reset_token), params: { email: @user.email,
                                                                user: { password: 'hogehoge',
                                                                        password_confirmation: 'hogehoge' } }
        expect(flash[:danger]).to include 'Password reset has expired.'
      end
    end

    context '無効なパスワードの場合' do
      it 'パスワードが空の場合はエラーメッセージが表示されること' do
        patch password_reset_path(@user.reset_token), params: { email: @user.email,
                                                                user: { password: '',
                                                                        password_confirmation: '' } }
        expect(response.body).to include 'The form contains 1 error.'
      end

      it 'パスワードと確認用パスワードが一致しない場合はエラーメッセージが表示されること' do
        patch password_reset_path(@user.reset_token), params: { email: @user.email,
                                                                user: { password: 'hogehoge',
                                                                        password_confirmation: '' } }
        expect(response.body).to include 'The form contains 1 error.'
      end
    end

    context '有効なパスワードの場合' do
      before do
        patch password_reset_path(@user.reset_token), params: { email: @user.email,
                                                                user: { password: 'hogehoge',
                                                                        password_confirmation: 'hogehoge' } }
      end

      it 'ログイン状態になること' do
        expect(logged_in?).to be_truthy
      end

      it 'flashが存在すること' do
        expect(flash[:success]).not_to be_empty
      end

      it 'ユーザーの詳細ページにリダイレクトすること' do
        expect(response).to redirect_to @user
      end

      it 'reset_digestがnilに更新されること' do
        expect(@user.reload.reset_digest).to be_nil
      end
    end
  end
end
