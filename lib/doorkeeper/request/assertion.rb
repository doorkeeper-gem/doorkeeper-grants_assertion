module Doorkeeper
  module Request
    class Assertion < Strategy
      delegate :credentials, :resource_owner, :parameters, to: :server
      attr_accessor :resource_owner

      def initialize(server)
        super
        @resource_owner = server.resource_owner_from_assertion
      end

      def request
        @request ||= OAuth::PasswordAccessTokenRequest.new(
          Doorkeeper.configuration,
          client,
          resource_owner,
          parameters
        )
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
