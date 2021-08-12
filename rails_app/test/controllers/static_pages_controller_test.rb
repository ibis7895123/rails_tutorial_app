require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  setup { @base_title = 'Ruby on Rails Tutorial Sample App' }

  test '正常系_ルートページGET' do
    get root_url
    assert_response :success
    assert_select 'title', "#{@base_title}"
  end

  test '正常系_ヘルプページGET' do
    get help_url
    assert_response :success
    assert_select 'title', "Help | #{@base_title}"
  end

  test '正常系_AboutページGET' do
    get about_url
    assert_response :success
    assert_select 'title', "About | #{@base_title}"
  end

  test '正常系_問い合わせページGET' do
    get contact_url
    assert_response :success
    assert_select 'title', "Contact | #{@base_title}"
  end
end
