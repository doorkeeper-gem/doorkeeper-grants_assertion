require "doorkeeper/request/assertion"
require "doorkeeper/grants_assertion/railtie"

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
  class Request
    def get_strategy(strategy, available)
      strategy = "assertion" if strategy == "urn:ietf:params:oauth:grant-type:jwt-bearer"
      fail Errors::MissingRequestStrategy unless strategy.present?
      fail NameError unless available.include?(strategy.to_s)
      "Doorkeeper::Request::#{strategy.to_s.camelize}".constantize
    end
  end
end

module Doorkeeper
  class Config
    option :resource_owner_from_assertion, default: (lambda do |routes|
        warn(I18n.t("doorkeeper.errors.messages.assertion_flow_not_configured"))
        nil
      end)
  end
end
