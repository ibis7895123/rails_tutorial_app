ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
MiniTest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # セッションにユーザーIDがあればtrue
  def is_logged_in_session_test?
    return !session[:user_id].nil?
  end

  # テストユーザーとしてログインする(単体テスト用)
  def log_in_as_test(user)
    session[:user_id] = user.id
  end

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  # テストユーザーとしてログインする(統合テスト用)
  def log_in_as_test(user, password: 'password', remember_me: '1')
    post login_path,
         params: {
           session: {
             email: user.email,
             password: password,
             remember_me: remember_me
           }
         }
  end
end
