module Doorkeeper
  module GrantsAssertion
    class Railtie < ::Rails::Railtie
      initializer "doorkeeper.grants_assertion" do
        Doorkeeper::Helpers::Controller.send :include, Doorkeeper::GrantsAssertion
      end
    end
  end
end
