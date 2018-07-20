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

FACEBOOK_INVALID_TOKEN =
  "invalid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
FACEBOOK_VALID_TOKEN = "valid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
GOOGLE_URL = "https://www.googleapis.com/plus/v1/people/me/openIdConnect"
GOOGLE_VALID_TOKEN = "valid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
GOOGLE_INVALID_TOKEN = "invalid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# rubocop:disable Metrics/BlockLength
RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, GOOGLE_URL).
      with(
        headers: {
         "Accept" => "*/*",
         "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
         "Authorization" => "Bearer #{GOOGLE_VALID_TOKEN}",
         "User-Agent" => /Faraday/
        }
      ).to_return(
        status: 200,
        body: (
          <<~HEREDOC
            {
              "kind": "plus#personOpenIdConnect",
              "gender": "male",
              "sub": "1234567890",
              "name": "Jack Jackson",
              "given_name": "Samuel",
              "family_name": "Jackson",
              "profile": "https://plus.google.com/1234567890",
              "picture": "http://lh3.googleusercontent.com/photo.jpg",
              "email": "u123456789@mail.com",
              "email_verified": "true",
              "locale": "en-US"
            }
          HEREDOC
        ),
        headers: {
          "Content-Type" => "application/json"
        }
      )

    stub_request(:get, GOOGLE_URL).
      with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization" => "Bearer #{GOOGLE_INVALID_TOKEN}",
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


    stub_request(
      :get,
      %r{
        https\:\/\/graph\.facebook\.com\/v\d\.\d\/me\?appsecret_proof\=\w+\&
        fields=email\,\%20first_name\,\%20last_name\,\%20gender\,\%20picture
      }x
    ).with(
      headers: {
       "Accept" => "*/*",
       "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
       "Authorization" => "Bearer #{FACEBOOK_INVALID_TOKEN}",
       "User-Agent" => /Faraday/
      }
    ).to_return(
      status: 400,
      body: (
        <<~HEREDOC
          {
            "error":{
              "message":"Malformed access token #{FACEBOOK_INVALID_TOKEN}",
              "type":"OAuthException",
              "code":190,"fbtrace_id":"1A2B3C4D"
            }
          }
        HEREDOC
      ),
      headers: {
        "Content-Type" => "application/json"
      }
    )

    stub_request(
      :get,
      %r{
        https\:\/\/graph\.facebook\.com\/v\d\.\d\/me\?appsecret_proof\=\w+\&
        fields=email\,\%20first_name\,\%20last_name\,\%20gender\,\%20picture
      }x
    ).with(
      headers: {
       "Accept" => "*/*",
       "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
       "Authorization" => "Bearer #{FACEBOOK_VALID_TOKEN}",
       "User-Agent" => /Faraday/
      }
    ).to_return(
      status: 200,
      body: (
        <<~HEREDOC
          {
            "email":"u123456789\u0040mail.com",
            "first_name":"Samuel",
            "last_name":"Jackson",
            "gender":"male",
            "picture":{
              "data":{
                "height":50,
                "is_silhouette":false,
                "url":"http:\/\/graph.facebook.com\/some_picture",
                "width":50
              }
            },
            "id":"102030405060708090"
          }
        HEREDOC
      ),
      headers: {
        "Content-Type" => "application/json"
      }
    )
  end
end
# rubocop:enable Metrics/BlockLength
