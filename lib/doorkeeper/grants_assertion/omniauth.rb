# frozen_string_literal: true

module Doorkeeper
  module GrantsAssertion
    module OmniAuth
      class << self
        # Reuses OmniAuth strategy implementation, such as facebook or google.
        # This allows you to share find/create methods with devise.
        # Usage:
        # resource_owner_from_assertion do
        #   auth = Doorkeeper::GrantsAssertion::OmniAuth.oauth2_wrapper(
        #     strategy_class: OmniAuth::Strategies:::GoogleOauth2,
        #     client_id: ENV["GOOGLE_CLIENT_ID"],
        #     client_secret: ENV["GOOGLE_CLIENT_SECRET"],
        #     client_options: { skip_image_info: false },
        #     assertion: params.fetch(:assertion)
        #   ).auth_hash rescue nil
        #   unless auth.nil?
        #     User.find_by(google_id: auth['id'])
        #   end
        # end
        def oauth2_wrapper(
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
          default_options = {
            name: strategy_class.to_s.split("::").last.downcase
          }
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
