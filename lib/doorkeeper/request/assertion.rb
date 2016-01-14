module Doorkeeper
  module Request
    class Assertion
      attr_accessor :credentials, :resource_owner, :server

      def initialize(server)
        @credentials, @resource_owner, @server = server.credentials, server.resource_owner_from_assertion, server
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
