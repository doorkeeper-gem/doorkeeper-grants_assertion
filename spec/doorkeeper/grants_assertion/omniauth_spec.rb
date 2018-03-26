# frozen_string_literal: true

require 'spec_helper'

describe ::Doorkeeper::GrantsAssertion::OmniAuth do
  describe ".oauth2_wrapper" do
    let(:provider) { "test-provider" }
    let(:strategy_class) { OmniAuth::Strategies::OAuth2 }
    let(:client_id) { "123456789" }
    let(:client_secret) { "987654321" }
    let(:client_options) { { please: "work" } }
    let(:assertion) { "QWERTYUIOPASDFGHJKLZXCVBNM1234567890098765321" }
    let(:expires_at) { nil }
    let(:expires_in) { nil }
    let(:refresh_token) { nil }
    let(:params) {
      {
        provider: provider,
        strategy_class: strategy_class,
        client_id: client_id,
        client_secret: client_secret,
        client_options: client_options,
        assertion: assertion,
        expires_at: expires_at,
        expires_in: expires_in,
        refresh_token: refresh_token,
      }
    }

    subject { described_class.oauth2_wrapper(params) }

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
end
