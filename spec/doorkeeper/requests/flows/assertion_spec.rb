# frozen_string_literal: true

require 'spec_helper_integration'

describe 'Resource Owner Assertion Flow inproperly set up', type: :request do
  before do
    config_is_set(:resource_owner_from_assertion) { nil }
    client_exists
    create_resource_owner
  end

  context 'with valid user assertion' do
    it "should not issue new token" do
      expect {
        post assertion_endpoint_url(client: @client, resource_owner: @resource_owner)
      }.to_not change { Doorkeeper::AccessToken.count }

      should_have_json 'error', 'invalid_grant'
      should_have_json 'error_description', translated_error_message(:invalid_grant)
      expect(response.status).to eq(401)
    end
  end
end

describe 'Resource Owner Assertion Flow', type: :request do
  before do
    config_is_set(:resource_owner_from_assertion) {
      User.where(assertion: params[:assertion]).first
    }
    client_exists
    create_resource_owner
  end

  context "with invalid client/application information" do

    it "should not create an access token" do
      expect {
        post assertion_endpoint_url(
          client_id: 'not-real',
          client_secret: 'not-real',
          redirect_uri: 'http://fake-redirect.com'
        )
      }.to_not change { Doorkeeper::AccessToken.count }
    end
  end

  context "with missing client/application information" do
    let(:no_client_params) {
      {
        grant_type: "assertion",
        assertion: @resource_owner.assertion
      }
    }

    it "should create an access token" do
      expect {
        post "/oauth/token?#{build_query(no_client_params)}"
      }.to change { Doorkeeper::AccessToken.count }.by(1)
    end

    context "when client is required as part of assertion lookup" do

      before do
        config_is_set(:resource_owner_from_assertion) {
          if server.client
            User.where(assertion: params[:assertion]).first
          end
        }
      end

      it "should not create an access token" do
        expect {
          post "/oauth/token?#{build_query(no_client_params)}"
        }.to change { Doorkeeper::AccessToken.count }.by(0)
      end
    end
  end

  context 'with valid user assertion' do
    it "should issue new token" do
      expect {
        post assertion_endpoint_url(client: @client, resource_owner: @resource_owner)
      }.to change { Doorkeeper::AccessToken.count }.by(1)

      token = Doorkeeper::AccessToken.first

      should_have_json 'access_token',  token.token
    end

    it "should associate the token with the appropriate application" do
      post assertion_endpoint_url(client: @client, resource_owner: @resource_owner)

      token = Doorkeeper::AccessToken.first

      expect(token.application_id).to eq(@client.id)
    end

    it "should issue a refresh token if enabled" do
      config_is_set(:refresh_token_enabled, true)

      post assertion_endpoint_url(client: @client, resource_owner: @resource_owner)

      token = Doorkeeper::AccessToken.first

      should_have_json 'refresh_token',  token.refresh_token
    end

  end

  context "with invalid user assertion" do
    it "should not issue new token with bad assertion" do
      expect {
        post assertion_endpoint_url( client: @client, assertion: 'i_dont_exist' )
      }.to_not change { Doorkeeper::AccessToken.count }

      should_have_json 'error', 'invalid_grant'
      should_have_json 'error_description', translated_error_message(:invalid_grant)
      expect(response.status).to eq(401)
    end

    it "should not issue new token without assertion" do
      expect {
        post assertion_endpoint_url( client: @client )
      }.to_not change { Doorkeeper::AccessToken.count }

      should_have_json 'error', 'invalid_grant'
      should_have_json 'error_description', translated_error_message(:invalid_grant)
      expect(response.status).to eq(401)
    end

  end
end

describe 'Resource Owner Assertion Flow with Devise OmniAuth', type: :request do
  before do
    config_is_set(:resource_owner_from_assertion) {
      if params[:provider] && params[:assertion]
        auth = Doorkeeper::GrantsAssertion::Devise::OmniAuth.auth_hash(
          provider: params.fetch(:provider),
          assertion: params.fetch(:assertion)
        )
        User.where(email: auth.info.email).first if auth
      end
    }
    client_exists
    create_resource_owner
  end

  context "with invalid client/application information" do

    it "should not create an access token" do
      expect {
        post assertion_endpoint_url(
          client_id: 'not-real',
          client_secret: 'not-real',
          redirect_uri: 'http://fake-redirect.com',
          provider: "facebook",
          assertion: "valid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        )
      }.to_not change { Doorkeeper::AccessToken.count }
    end
  end

  context "with missing client/application information" do
    let(:no_client_params) {
      {
        grant_type: "assertion",
        provider: "facebook",
        assertion: "valid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
      }
    }

    it "should create an access token" do
      expect {
        post "/oauth/token?#{build_query(no_client_params)}"
      }.to change { Doorkeeper::AccessToken.count }.by(1)
    end

    context "when client is required as part of assertion lookup" do

      before do
        config_is_set(:resource_owner_from_assertion) {
          if server.client && params[:provider] && params[:assertion]
            auth = Doorkeeper::GrantsAssertion::Devise::OmniAuth.auth_hash(
              provider: params.fetch(:provider),
              assertion: params.fetch(:assertion)
            )
            User.where(email: auth.info.email).first if auth
          end
        }
      end

      it "should not create an access token" do
        expect {
          post "/oauth/token?#{build_query(no_client_params)}"
        }.to change { Doorkeeper::AccessToken.count }.by(0)
      end
    end
  end

  context 'with valid facebook user assertion' do
    it "should issue new token" do
      expect {
        post assertion_endpoint_url(
          client: @client,
          provider: "facebook",
          assertion: "valid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        )
      }.to change { Doorkeeper::AccessToken.count }.by(1)

      token = Doorkeeper::AccessToken.first

      should_have_json 'access_token',  token.token
    end

    it "should associate the token with the appropriate application" do
      post assertion_endpoint_url(
        client: @client,
        provider: "facebook",
        assertion: "valid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
      )

      token = Doorkeeper::AccessToken.first

      expect(token.application_id).to eq(@client.id)
    end

    it "should issue a refresh token if enabled" do
      config_is_set(:refresh_token_enabled, true)

      post assertion_endpoint_url(
        client: @client,
        provider: "facebook",
        assertion: "valid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
      )
      token = Doorkeeper::AccessToken.first

      should_have_json 'refresh_token',  token.refresh_token
    end
  end

  context 'with valid google user assertion' do
    it "should issue new token" do
      expect {
        post assertion_endpoint_url(
          client: @client,
          provider: "google",
          assertion: "valid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        )
      }.to change { Doorkeeper::AccessToken.count }.by(1)

      token = Doorkeeper::AccessToken.first

      should_have_json 'access_token',  token.token
    end

    it "should associate the token with the appropriate application" do
      post assertion_endpoint_url(
        client: @client,
        provider: "google",
        assertion: "valid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      )

      token = Doorkeeper::AccessToken.first

      expect(token.application_id).to eq(@client.id)
    end

    it "should issue a refresh token if enabled" do
      config_is_set(:refresh_token_enabled, true)

      post assertion_endpoint_url(
        client: @client,
        provider: "google",
        assertion: "valid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      )
      token = Doorkeeper::AccessToken.first

      should_have_json 'refresh_token',  token.refresh_token
    end
  end

  context "with invalid user assertion" do
    it "should not issue new token with bad facebook assertion" do
      expect {
        post assertion_endpoint_url(
          client: @client,
          provider: "facebook",
          assertion: "invalid_token_ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
        )
      }.to_not change { Doorkeeper::AccessToken.count }

      should_have_json 'error', 'invalid_grant'
      should_have_json 'error_description', translated_error_message(:invalid_grant)
      expect(response.status).to eq(401)
    end

    it "should not issue new token with bad google assertion" do
      expect {
        post assertion_endpoint_url(
          client: @client,
          provider: "google",
          assertion: "invalid_token_1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        )
      }.to_not change { Doorkeeper::AccessToken.count }

      should_have_json 'error', 'invalid_grant'
      should_have_json 'error_description', translated_error_message(:invalid_grant)
      expect(response.status).to eq(401)
    end

    it "should not issue new token without assertion" do
      expect {
        post assertion_endpoint_url( client: @client , provider: "tester")
      }.to_not change { Doorkeeper::AccessToken.count }

      should_have_json 'error', 'invalid_grant'
      should_have_json 'error_description', translated_error_message(:invalid_grant)
      expect(response.status).to eq(401)
    end

  end
end
