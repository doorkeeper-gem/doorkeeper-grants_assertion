module Doorkeeper
  module Request
    class Assertion
      attr_accessor :resource_owner, :server

      delegate :credentials, :parameters, to: :server

      def initialize(server)
        @resource_owner = server.resource_owner_from_assertion
        @server = server
      end

      def request
        @request ||= OAuth::PasswordAccessTokenRequest.new(
          Doorkeeper.configuration,
          client,
          resource_owner,
          parameters
        )
      end

      def authorize
        request.authorize
      end

      private

      def client
        if credentials
          server.client
        elsif parameters[:client_id]
          server.client_via_uid
        end
      end
    end
  end
end
