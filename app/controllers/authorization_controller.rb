# -*- coding: utf-8 -*-
class AuthorizationController < ApplicationController

  def authorize
    redirect_to authz.authorization_uri(new_state, new_nonce)
  end

  def callback
    # @see http://openid-foundation-japan.github.io/openid-connect-core-1_0.ja.html#FragmentNotes
  end

  def validate

    if params['error']
      puts "error=#{params['error']}, description=#{params['error_description']}"
      render :nothing => true, :status => 400
      return
    end

    unless authz.validate(params, stored_state, stored_nonce) == true
      render :nothing => true, :status => 400
      return
    end

    session[:id_token] = (authz.oidc.id_token).as_json
    session[:user_info] =  (authz.oidc.user_info).as_json
  end

  # TODO: ログアウト機能の実装
  def logout
    delete_session!
    redirect_to root_url
  end

  private

  def authz
    @authz ||= Authorization.new oidc_param
  end

  def oidc_param
    @oidc_param ||= default_param
  end

  def delete_session!
    session.delete(:id_token)
    session.delete(:user_info)
  end

  def default_param
    {
        :issuer => 'op.example.com',
        :identifier => ENV['CLIENT_ID'],
        :jwks_uri => 'http://localhost:3000/jwks',
        :authorization_endpoint => 'http://localhost:3000/authorization',
        :token_endpoint => 'https://localhost:3000/token',
        :userinfo_endpoint => 'https://localhost:3000/userinfo',
        :redirect_uri => ENV['CALLBACK_URL']
    }
  end
end

