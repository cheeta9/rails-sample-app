require 'rails_helper'

RSpec.describe 'Microposts', type: :request do
  describe 'POST /microposts' do
    context 'ログインしていないの場合' do
      it '登録できないこと' do
        expect { post microposts_path, params: { micropost: { content: 'test' } } }.not_to change(Micropost, :count)
      end

      it 'ログインページにリダイレクトすること' do
        post microposts_path, params: { micropost: { content: 'test' } }
        expect(response).to redirect_to login_path
      end
    end
  end

  describe 'DELETE /micropsots/{id}' do
    let!(:user) { FactoryBot.create(:user) }
    let!(:micropost) { FactoryBot.create(:micropost, user: user) }

    context 'ログインしていないの場合' do
      it '削除できないこと' do
        expect { delete micropost_path(micropost) }.not_to change(Micropost, :count)
      end

      it 'ログインページにリダイレクトすること' do
        delete micropost_path(micropost)
        expect(response).to redirect_to login_path
      end
    end

    context 'ログインしている場合' do
      before { log_in user }

      context '他のユーザーのマイクロポストを削除しようとした場合' do
        let!(:other_user) { FactoryBot.create(:other_user) }
        let!(:other_micropost) { FactoryBot.create(:micropost, user: other_user) }

        it '削除できないこと' do
          expect { delete micropost_path(other_micropost) }.not_to change(Micropost, :count)
        end

        it 'rootページにリダイレクトすること' do
          delete micropost_path(other_micropost)
          expect(response).to redirect_to root_path
        end
      end

      context '自身のマイクロポストを削除しようとした場合' do
        it '削除できること' do
          expect { delete micropost_path(micropost) }.to change(Micropost, :count).by(-1)
        end
      end
    end
  end
end
