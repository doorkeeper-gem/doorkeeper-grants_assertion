# frozen_string_literal: true

require "doorkeeper/request/assertion"

require "doorkeeper/grants_assertion/railtie"
require "doorkeeper/grants_assertion/omniauth"
require "doorkeeper/grants_assertion/devise/omniauth"

module Doorkeeper
  module GrantsAssertion
    def resource_owner_from_assertion
      instance_eval(&Doorkeeper.configuration.resource_owner_from_assertion)
    end
  end
end

module Doorkeeper
  class Server
    def resource_owner_from_assertion
      context.send :resource_owner_from_assertion
    end
  end
end

module Doorkeeper
  class Config
    option :resource_owner_from_assertion, default: (lambda do |_routes|
        warn(I18n.t("doorkeeper.errors.messages.assertion_flow_not_configured"))
        nil
      end)
  end
end
