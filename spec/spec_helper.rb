# frozen_string_literal: true

require "webmock/rspec"
require "rails"
require "omniauth-oauth2"
require "omniauth-facebook"
require "omniauth-google-oauth2"
require "devise"
require "doorkeeper"
require "doorkeeper/grants_assertion"

WebMock.disable_net_connect!
