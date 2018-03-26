# frozen_string_literal: true

module Doorkeeper
  module GrantsAssertion
    class Railtie < ::Rails::Railtie
      initializer "doorkeeper.grants_assertion.params.filter" do |app|
        app.config.filter_parameters << "assertion"
      end

      initializer "doorkeeper.grants_assertion" do
        Doorkeeper::Helpers::Controller.send :include, Doorkeeper::GrantsAssertion
      end
    end
  end
end
