# frozen_string_literal: true

module Doorkeeper
  module GrantsAssertion
    module Devise
      module OmniAuth
        class << self
          def auth_hash(provider:, assertion:)
            devise_config = ::Devise.omniauth_configs[provider.to_sym]
            fail("Invalid Assertion Provider") if devise_config.nil?
            oauth2_wrapper(provider, devise_config, assertion).auth_hash
          rescue OAuth2::Error => _exception
            nil
          end

          private

          def oauth2_wrapper(provider, devise_config, assertion)
            client_id, client_secret, client_options = devise_config.args
            Doorkeeper::GrantsAssertion::OmniAuth.oauth2_wrapper(
              provider: provider,
              strategy_class: devise_config.strategy_class,
              client_id: client_id,
              client_secret: client_secret,
              client_options: client_options,
              assertion: assertion
            )
          end
        end
      end
    end
  end
end
