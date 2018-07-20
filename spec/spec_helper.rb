# frozen_string_literal: true

require "webmock/rspec"
require "rails"
require "omniauth-oauth2"
require "omniauth-facebook"
require "omniauth-google-oauth2"
require "devise"
require "doorkeeper"
require "doorkeeper/grants_assertion"

WebMock.disable_net_connect!

RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, "https://www.googleapis.com/plus/v1/people/me/openIdConnect").
      with(
        headers: {
         "Accept" => "*/*",
         "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
         "Authorization" => "Bearer valid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ",
         "User-Agent" => /Faraday/
        }
      ).to_return(
        status: 200,
        body: '{ "kind": "plus#personOpenIdConnect", "gender": "male", "sub": "1234567890", "name": "Jack Jackson", "given_name": "Samuel", "family_name": "Jackson", "profile": "https://plus.google.com/1234567890", "picture": "http://lh3.googleusercontent.com/photo.jpg", "email": "u123456789@mail.com", "email_verified": "true", "locale": "en-US" }',
        headers: {
          "Content-Type" => "application/json"
        }
      )

    stub_request(:get, "https://www.googleapis.com/plus/v1/people/me/openIdConnect").
      with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer invalid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ",
          "User-Agent" => /Faraday/
        }
      ).to_return(
        status: 401,
        body: (
          <<~HEREDOC
            {
              "error": {
                "errors": [
                  {
                    "domain": "global",
                    "reason": "authError",
                    "message": "Invalid Credentials",
                    "locationType": "header",
                    "location": "Authorization"
                  }
                ],
                "code": 401,
                "message": "Invalid Credentials"
              }
            }
          HEREDOC
        ),
        headers: {
          "Content-Type" => "application/json"
        }
      )

    stub_request(:get, /https\:\/\/graph\.facebook\.com\/v2\.6\/me\?appsecret_proof\=\w+\&fields=email\,\%20first_name\,\%20last_name\,\%20gender\,\%20picture/).
      with(
        headers: {
         "Accept" => "*/*",
         "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
         "Authorization" => "Bearer invalid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
         "User-Agent" => /Faraday/
        }
      ).to_return(
        status: 400,
        body: '{"error":{"message":"Malformed access token invalid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890","type":"OAuthException","code":190,"fbtrace_id":"1A2B3C4D"}}',
        headers: {
          "Content-Type" => "application/json"
        }
      )

    stub_request(:get, /https\:\/\/graph\.facebook\.com\/v2\.6\/me\?appsecret_proof\=\w+\&fields=email\,\%20first_name\,\%20last_name\,\%20gender\,\%20picture/).
      with(
        headers: {
         "Accept" => "*/*",
         "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
         "Authorization" => "Bearer valid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
         "User-Agent" => /Faraday/
        }
      ).to_return(
        status: 200,
        body: '{"email":"u123456789\u0040mail.com","first_name":"Samuel","last_name":"Jackson","gender":"male","picture":{"data":{"height":50,"is_silhouette":false,"url":"http:\/\/graph.facebook.com\/some_picture","width":50}},"id":"102030405060708090"}',
        headers: {
          "Content-Type" => "application/json"
        }
      )
  end
end
