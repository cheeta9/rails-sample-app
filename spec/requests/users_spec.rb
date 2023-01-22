require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'GET /users' do
    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトすること' do
        get users_path
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to login_path
      end
    end

    context 'ログインしている場合' do
      let!(:user) { FactoryBot.create(:user) }

      it '正常にレスポンスを返すこと' do
        log_in(user)
        get users_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include full_title('All users')
      end
    end
  end

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

  describe 'GET /user/{id}/edit' do
    let!(:user) { FactoryBot.create(:user) }

    context 'ログインしていない場合' do
      it 'flashが空でないこと' do
        get edit_user_path(user)
        expect(flash[:danger]).not_to be_empty
      end

      it 'ログインページにリダイレクトすること' do
        get edit_user_path(user)
        expect(response).to redirect_to login_path
      end

      it 'ログインすると編集ページにリダイレクトすること' do
        get edit_user_path(user)
        expect(session[:forwarding_url]).to eq edit_user_url(user)
        log_in(user)
        expect(response).to redirect_to edit_user_path(user)
        expect(session[:forwarding_url]).to be_blank
      end
    end

    context '別のユーザーの場合' do
      let!(:other_user) do
        FactoryBot.create(:other_user)
      end

      before do
        log_in(user)
        get edit_user_path(other_user)
      end

      it 'flashが空であること' do
        expect(flash).to be_blank
      end

      it 'rootページにリダイレクトすること' do
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'PATCH /users' do
    let!(:user) { FactoryBot.create(:user) }
    before do
      patch user_path(user), params: { user: { name: user.name,
                                               email: user.email } }
    end

    context 'ログインしていない場合' do
      it 'flashが空でないこと' do
        expect(flash[:danger]).not_to be_empty
      end

      it 'ログインページにリダイレクトすること' do
        expect(response).to redirect_to login_path
      end
    end

    context '無効な値の場合' do
      before { log_in(user) }

      it '更新できないこと' do
        dup_user = user.dup
        patch user_path(user), params: { user: { name: '',
                                                 email: 'foo@invalid',
                                                 password: 'foo',
                                                 password_confirmation: 'bar' } }
        user.reload
        expect(user.name).to eq dup_user.name
        expect(user.email).to eq dup_user.email
        expect(user.password).to eq dup_user.password
        expect(user.password_confirmation).to eq dup_user.password_confirmation
      end

      it '更新失敗後にeditページが表示されていること' do
        patch user_path(user), params: { user: { name: '',
                                                 email: 'foo@invalid',
                                                 password: 'foo',
                                                 password_confirmation: 'bar' } }
        expect(response.body).to include full_title('Edit user')
        expect(response.body).to include 'The form contains 4 errors.'
      end

      it 'admin属性は更新できないこと' do
        expect(user).not_to be_admin
        patch user_path(user), params: { user: { password: 'foobar',
                                                 password_confirmation: 'foobar',
                                                 admin: true } }
        user.reload
        expect(user).not_to be_admin
      end
    end

    context '有効な値の場合' do
      let!(:name) { 'Foo Bar' }
      let!(:email) { 'foo@bar.com' }
      before do
        log_in(user)
        patch user_path(user), params: { user: { name: name,
                                                 email: email,
                                                 password: '',
                                                 password_confirmation: '' } }
      end

      it '更新できること' do
        user.reload
        expect(user.name).to eq name
        expect(user.email).to eq email
      end

      it 'showページにリダイレクトすること' do
        expect(response).to redirect_to user
      end

      it 'flashが表示されていること' do
        expect(flash[:success]).not_to be_empty
      end
    end
  end

  describe 'DELETE /users/{id}' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:other_user) { FactoryBot.create(:other_user) }
    let!(:admin_user) { FactoryBot.create(:admin_user) }

    context 'ログインしていない場合' do
      it '削除できないこと' do
        expect { delete user_path(user) }.not_to change(User, :count)
      end

      it 'ログインページにリダイレクトすること' do
        delete user_path(user)
        expect(response).to redirect_to login_path
      end
    end

    context 'ログインしている場合' do
      context 'adminでない場合' do
        before { log_in(user) }

        it '削除できないこと' do
          expect { delete user_path(other_user) }.not_to change(User, :count)
        end

        it 'rootページにリダイレクトすること' do
          delete user_path(other_user)
          expect(response).to redirect_to root_path
        end
      end

      context 'adminである場合' do
        before { log_in(admin_user) }

        it '削除できること' do
          expect { delete user_path(other_user) }.to change(User, :count).by(-1)
        end

        it 'ユーザー一覧ページにリダイレクトすること' do
          delete user_path(other_user)
          expect(response).to redirect_to users_path
        end
      end
    end
  end
end
