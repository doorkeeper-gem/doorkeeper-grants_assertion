module Doorkeeper
  module Request
    class Assertion < Strategy
      delegate :credentials, :resource_owner_from_assertion, :parameters, to: :server

      def request
        @request ||= OAuth::PasswordAccessTokenRequest.new(
          Doorkeeper.configuration,
          client,
          resource_owner_from_assertion,
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
