# -*- coding: utf-8 -*-
require 'base64'

class Authorization < ActiveModelBase

  include State
  include Nonce

  attr_accessor :issuer, :identifier, :jwks_uri,
                :authorization_endpoint,
                :token_endpoint,
                :userinfo_endpoint,
                :redirect_uri

  # Authorization Endpoint の URI をリクエストパラメータ付きで返却します。
  # @see http://openid-foundation-japan.github.io/openid-connect-core-1_0.ja.html#AuthorizationEndpoint
  #
  # @param [String] nonce (number used once) リプレイアタックを軽減するために用いられる文字列の値。
  # @return [String] authorization_uri
  def authorization_uri(state, nonce)
    client.redirect_uri ||= redirect_uri
    client.authorization_uri(
        response_type: [:id_token].collect(&:to_s),
        state: state,
        nonce: nonce,
        scope: [:openid, :email, :profile].collect(&:to_s)
    )
  end

  # Authorization Endpoint から Redirection URI フラグメントのパラメータを検証します。
  #
  # @param [Hash] fragment URIフラグメントのパラメータ
  # @param [String] nonce
  # @return [Boolean] 検証結果 true|false
  def validate(fragment, state, nonce)

    #stateパラメータのチェック
    unless fragment['state'] == state then
      puts 'invalid state parameter.'
      return false
    end

    # ID Tokenの検証
    begin
      id_token = decode_id_token fragment['id_token']
      id_token.verify!(
          issuer: issuer,
          client_id: identifier,
          nonce: nonce
      )
      oidc.id_token = id_token
      oidc.user_info = id_token.raw_attributes['userinfo']
    rescue => e
      puts "error, #{e.message}"
      return false
    end

    return true
  end

  def oidc
    @oidc||= OIDC.new
  end

  private

  def client
    @client ||= OpenIDConnect::Client.new member_to_json
  end

  def member_to_json
    [:issuer, :identifier, :jwks_uri,
     :authorization_endpoint,
     :token_endpoint,
     :userinfo_endpoint
    ].inject({}) do |hash, key|
      hash.merge!(
          key => self.send(key)
      )
    end
  end

  def decode_id_token(id_token)
    OpenIDConnect::ResponseObject::IdToken.decode id_token, public_keys.first
  end

  def jwks
    @jwks ||= JSON.parse(OpenIDConnect.http_client.get_content(jwks_uri)).with_indifferent_access
    JSON::JWK::Set.new @jwks
  end

  #OpenIDConnect::Discovery::Provider::Config::Response
  def public_keys
    @public_keys ||= jwks.collect do |jwk|
      JSON::JWK.decode jwk
    end
  end


end
