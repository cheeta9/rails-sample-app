require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "account_activation" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:mail) { UserMailer.account_activation(user) }

    before { user.activation_token = User.new_token }

    it '送信メールのタイトルが正しいこと' do
      expect(mail.subject).to eq 'Account activation'
    end

    it '送信メールの送信先が正しいこと' do
      expect(mail.to).to eq [user.email]
    end

    it '送信メールの送信元が正しいこと' do
      expect(mail.from).to eq ['noreply@example.com']
    end

    it '送信メールの本文にユーザー名が表示されていること' do
      expect(mail.body.encoded).to match user.name
    end

    it '送信メールの本文にactivation_tokenが表示されていること' do
      expect(mail.body.encoded).to match user.activation_token
    end

    it '送信メールの本文にユーザーのemailアドレスが表示されていること' do
      expect(mail.body.encoded).to match CGI.escape(user.email)
    end
  end

  describe "password_reset" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:mail) { UserMailer.password_reset(user) }

    before { user.reset_token = User.new_token }

    it '送信メールのタイトルが正しいこと' do
      expect(mail.subject).to eq 'Password reset'
    end

    it '送信メールの送信先が正しいこと' do
      expect(mail.to).to eq [user.email]
    end

    it '送信メールの送信元が正しいこと' do
      expect(mail.from).to eq ['noreply@example.com']
    end

    it '送信メールの本文にreset_tokenが表示されていること' do
      expect(mail.body.encoded).to match user.reset_token
    end

    it '送信メールの本文にユーザーのemailアドレスが表示されていること' do
      expect(mail.body.encoded).to match CGI.escape(user.email)
    end
  end
end
