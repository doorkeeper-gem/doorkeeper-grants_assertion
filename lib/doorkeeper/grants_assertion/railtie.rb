module Doorkeeper
  module GrantsAssertion
    class Railtie < ::Rails::Railtie

      initializer "doorkeeper.grants_assertion" do
        Doorkeeper::ApplicationController.send :include, Doorkeeper::GrantsAssertion
      end

    end
  end
end
