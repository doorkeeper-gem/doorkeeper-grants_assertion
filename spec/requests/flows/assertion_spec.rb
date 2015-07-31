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
    config_is_set(:resource_owner_from_assertion) { User.where(assertion: params[:assertion]).first }
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
          Doorkeeper::Application.find_by!(uid: params[:client_id])
          User.where(assertion: params[:assertion]).first
        }
      end

      it "should not create an access token" do
        expect {
          post "/oauth/token?#{build_query(no_client_params)}"
        }.to raise_error(ActiveRecord::RecordNotFound)
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
