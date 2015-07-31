class MetalController < ActionController::Metal
  include AbstractController::Callbacks
  include ActionController::Head
  include Doorkeeper::Helpers::Controller

  before_action :doorkeeper_authorize!

  def index
    self.response_body = { ok: true }.to_json
  end
end
