require 'rails_helper'

RSpec.describe 'Relationships', type: :request do
  let!(:user) { FactoryBot.create(:user) }
  let!(:other_user) { FactoryBot.create(:other_user) }

  describe 'POST /relationships' do
    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトすること' do
        post relationships_path
        expect(response).to redirect_to login_path
      end

      it '登録されないこと' do
        expect { post relationships_path }.not_to change(Relationship, :count)
      end
    end

    context 'ログインしている場合' do
      before { log_in user }

      it '登録されること' do
        expect do
          post relationships_path, params: { followed_id: other_user.id }
        end.to change(Relationship, :count).by(1)
      end
    end
  end

  describe 'DELETE /relationships/{id}' do
    let!(:relationship) { FactoryBot.create(:relationship, follower: user, followed: other_user) }

    context 'ログインしていない場合' do
      it 'ログインページにリダイレクトすること' do
        delete relationship_path(relationship)
        expect(response).to redirect_to login_path
      end

      it '削除されないこと' do
        expect { delete relationship_path(relationship) }.not_to change(Relationship, :count)
      end
    end

    context 'ログインしている場合' do
      before { log_in user }

      it '削除されること' do
        expect { delete relationship_path(relationship) }.to change(Relationship, :count).by(-1)
      end
    end
  end
end
