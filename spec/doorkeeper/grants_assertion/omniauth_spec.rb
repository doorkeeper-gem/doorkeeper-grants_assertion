# frozen_string_literal: true

require "spec_helper"

describe ::Doorkeeper::GrantsAssertion::OmniAuth do
  describe ".oauth2_wrapper" do
    subject { described_class.oauth2_wrapper(params) }

    context "OAuth2 strategy" do
      let(:params) {
        {
          provider: "test-provider",
          strategy_class: OmniAuth::Strategies::OAuth2,
          client_id: "123456789",
          client_secret: "987654321",
          client_options: { please: "work" },
          assertion: "QWERTYUIOPASDFGHJKLZXCVBNM1234567890098765321",
          expires_at: nil,
          expires_in: nil,
          refresh_token: nil,
        }
      }

      describe "#auth_hash" do
        subject { super().auth_hash }
        it {
          expect(subject).to eq(
            "credentials" => {
              "token" => "QWERTYUIOPASDFGHJKLZXCVBNM1234567890098765321",
              "expires" => false,
            },
            "extra" => {},
            "info" => {},
            "provider" => "test-provider",
            "uid" => nil,
          )
        }
      end

      context "nil options" do
        let(:params) {
          {
            provider: nil,
            strategy_class: nil,
            client_id: nil,
            client_secret: nil,
            client_options: {},
            assertion: nil,
            expires_at: nil,
            expires_in: nil,
            refresh_token: nil,
          }
        }

        describe "#auth_hash" do
          subject { super().auth_hash }
          it {
            expect { subject }.to raise_error(
              TypeError,
              "superclass must be a Class (NilClass given)"
            )
          }
        end
      end
    end

    context "Facebook strategy" do
      let(:params) {
        {
          provider: :facebook,
          strategy_class: OmniAuth::Strategies::Facebook,
          client_id: "123456789",
          client_secret: "abcdefghijklmnopqrstuvwxyz",
          client_options: {
            scope: "email, public_profile",
            info_fields: "email, first_name, last_name, gender, picture",
            secure_image_url: true,
            image_size: "large"
          },
          assertion: "valid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
          expires_at: nil,
          expires_in: nil,
          refresh_token: nil,
        }
      }

      context "valid token" do
        describe "#auth_hash" do
          subject { super().auth_hash }
          it {
            expect(subject).to eq(
              "credentials" => {
                "token" => "valid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                "expires" => false,
              },
              "extra" => {
                "raw_info" => {
                  "email" => "u123456789@mail.com",
                  "first_name" => "Samuel",
                  "last_name" => "Jackson",
                  "gender" => "male",
                  "picture"=> {
                    "data" => {
                      "height" => 50,
                      "is_silhouette" => false,
                      "url" => "http://graph.facebook.com/some_picture",
                      "width" => 50
                    }
                  },
                  "id" => "102030405060708090"
                }
              },
              "info" => {
                "email" => "u123456789@mail.com",
                "first_name" => "Samuel",
                "last_name" => "Jackson",
                "image" => "https://graph.facebook.com/v2.6/102030405060708090/picture?type=large"
              },
              "provider" => :facebook,
              "uid" => "102030405060708090",
            )
          }
        end
      end

      context "invalid token" do
        let(:params) {
          {
            provider: :facebook,
            strategy_class: OmniAuth::Strategies::Facebook,
            client_id: "123456789",
            client_secret: "abcdefghijklmnopqrstuvwxyz",
            client_options: {
              scope: "email, public_profile",
              info_fields: "email, first_name, last_name, gender, picture",
              secure_image_url: true,
              image_size: "large"
            },
            assertion: "invalid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            expires_at: nil,
            expires_in: nil,
            refresh_token: nil,
          }
        }

        describe "#auth_hash" do
          subject { super().auth_hash }
          it {
            expect { subject }.to raise_error(
              OAuth2::Error,
            )
          }
        end
      end
    end
    context "Google strategy" do
      let(:params) {
        {
          provider: :google_oauth2,
          strategy_class: OmniAuth::Strategies::GoogleOauth2,
          client_id: "some-client-id.apps.googleusercontent.com",
          client_secret: "abcdefghijklmnopqrstuvwxyz",
          client_options: {},
          assertion: "valid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ",
          expires_at: nil,
          expires_in: nil,
          refresh_token: nil,
        }
      }
      context "valid token" do
        describe "#auth_hash" do
          subject { super().auth_hash }
          it {
            expect(subject).to eq(
              "credentials" => {
                "token" => "valid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ",
                "expires"=>false
              },
              "extra" => {
                "raw_info" => {
                  "kind" => "plus#personOpenIdConnect",
                  "gender" => "male",
                  "sub" => "1234567890",
                  "name" => "Jack Jackson",
                  "given_name" => "Samuel",
                  "family_name" => "Jackson",
                  "profile" => "https://plus.google.com/1234567890",
                  "picture" => "http://lh3.googleusercontent.com/photo.jpg",
                  "email" => "u123456789@mail.com",
                  "email_verified" => "true",
                  "locale" => "en-US"
                }
              },
              "info" => {
                "name" => "Jack Jackson",
                "email" => "u123456789@mail.com",
                "first_name" => "Samuel",
                "last_name" => "Jackson",
                "image" => "http://lh3.googleusercontent.com/photo.jpg",
                "urls" => {
                  "google" => "https://plus.google.com/1234567890"
                }
              },
              "provider" => :google_oauth2,
              "uid" => "1234567890",
            )
          }
        end
      end
      context "invalid token" do
        let(:params) {
          {
            provider: :google_oauth2,
            strategy_class: OmniAuth::Strategies::GoogleOauth2,
            client_id: "some-client-id.apps.googleusercontent.com",
            client_secret: "abcdefghijklmnopqrstuvwxyz",
            client_options: {},
            assertion: "invalid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            expires_at: nil,
            expires_in: nil,
            refresh_token: nil,
          }
        }

        describe "#auth_hash" do
          subject { super().auth_hash }
          it {
            expect { subject }.to raise_error(
              OAuth2::Error,
            )
          }
        end
      end
    end
  end
end
