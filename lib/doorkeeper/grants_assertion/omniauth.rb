# frozen_string_literal: true

module Doorkeeper
  module GrantsAssertion
    module OmniAuth
      class << self
        def oauth2_wrapper(
          provider:,
          strategy_class:,
          client_id:,
          client_secret:,
          client_options:,
          assertion:,
          expires_at: nil,
          expires_in: nil,
          refresh_token: nil
        )
          app = nil # strategy_class is a rack middleware
          default_options = { name: provider }
          options = default_options.merge(client_options)
          args = [client_id, client_secret, options]
          wrapper = Class.new(strategy_class).new(app, *args)
          wrapper.access_token = OAuth2::AccessToken.new(
            wrapper.client,
            assertion,
            expires_at: expires_at,
            expires_in: expires_in,
            refresh_token: refresh_token
          )
          wrapper
        end
      end
    end
  end
end
