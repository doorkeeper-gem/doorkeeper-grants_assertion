# frozen_string_literal: true

module Doorkeeper
  module Request
    class Assertion < Strategy
      delegate :credentials, :resource_owner_from_assertion, :parameters, to: :server

      def request
        @request ||= build_request
      end

      def authorize
        request.authorize
      end

      private

      def build_request
        if ::Gem::Dependency.new('', '>= 5.5.1').match?('', ::Doorkeeper::VERSION::STRING)
          OAuth::PasswordAccessTokenRequest.new(
            Doorkeeper.configuration,
            client,
            credentials,
            resource_owner_from_assertion,
            parameters
          )
        else
          OAuth::PasswordAccessTokenRequest.new(
            Doorkeeper.configuration,
            client,
            resource_owner_from_assertion,
            parameters
          )
        end
      end

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
