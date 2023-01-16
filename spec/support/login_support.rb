module LoginSupport
  # テストユーザーがログイン中の場合にtrueを返す
  def logged_in?
    !session[:user_id].nil?
  end
end

RSpec.configure do |config|
  config.include LoginSupport
end
