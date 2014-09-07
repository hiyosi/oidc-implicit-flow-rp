require 'test_helper'

class AuthorizationControllerTest < ActionController::TestCase

  include Nonce
  include State

  setup do
    ENV['CLIENT_ID'] = '123'
    ENV['CALLBACK_URL'] = 'https://localhost:3001/callback'

    @params = {
        :issuer => 'op.example.com',
        :identifier => ENV['CLIENT_ID'],
        :jwks_uri => 'http://localhost:3000/jwks',
        :authorization_endpoint => 'http://localhost:3000/authorization',
        :token_endpoint => 'https://localhost:3000/token',
        :userinfo_endpoint => 'https://localhost:3000/userinfo',
        :redirect_uri => ENV['CALLBACK_URL']
    }
  end

  test 'authorize action should redirect' do
    get :authorize
    assert_equal 302, response.status
  end

  test 'callback action should render callback template' do
    get :callback
    assert_equal 200, response.status
    assert_template :callback
  end

  test 'validate action should render validate template' do

    oidc = stub('OIDC')
    oidc.stubs(:id_token).returns({'foo' => 'bar'})
    oidc.stubs(:user_info).returns({'ham' => 'spam'})

    authz = stub('Authorization')
    authz.stubs(:validate).returns(true)
    authz.stubs(:oidc).returns(oidc)

    @controller.stubs(:authz).returns(authz)

    state = 'xyz'
    nonce = '123'

    get :validate, {
      'token_type' => 'Bearer',
      'id_token' => 'id_tokne_sample',
      'state' => state,
    }

    assert_equal 200, response.status
    assert_template :validate
  end

  test 'validate action should return 400 when request param with error' do
    get :validate, {
      'error' => 'test_error',
      'error_description' => 'this is a test error.'
    }
    assert_equal 400, response.status
  end

  test 'validate action should return 400 when invalid request params' do
    get :validate, {
      'token_type' => 'Bearer',
      'id_token' => 'id_tokne_sample',
      'state' => 'state123',
    }

    assert_equal 400, response.status
  end

  test 'logout action should redirect root_uri' do
    get :logout
    assert_equal 302, response.status
  end

  test 'logout action should remove session' do
    session['id_token'] = 'id_token'
    session['user_info'] = 'user_info'

    assert session['id_token']
    assert session['user_info']

    get :logout

    assert_equal nil, session['id_token']
    assert_equal nil, session['user_info']
  end

  test 'when rails Excption should redirect root' do
    @controller.stubs(:logout).raises(OpenIDConnect::Exception)

    get :logout
    assert_equal 302, response.status
  end

  test 'when rails Excption with long message should redirect root' do

    message = stub('String')
    message.stubs(:length).returns(3000)

    exp = OpenIDConnect::Exception.new('foo')
    exp.stubs(:message).returns(message)

    @controller.stubs(:logout).raises(exp)

    get :logout
    assert_equal 302, response.status
  end

end
