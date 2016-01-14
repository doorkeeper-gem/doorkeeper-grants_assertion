module Doorkeeper
  module Request
    class Assertion
      attr_accessor :credentials, :resource_owner, :server

      def initialize(server)
        @credentials = server.credentials
        @resource_owner = server.resource_owner_from_assertion
        @server = server
      end

      def request
        @request ||= OAuth::PasswordAccessTokenRequest.new(
          Doorkeeper.configuration,
          credentials,
          resource_owner,
          server.parameters)
      end

      def authorize
        request.authorize
      end
    end
  end
end
