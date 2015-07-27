class FullProtectedResourcesController < ApplicationController
  before_action :doorkeeper_authorize!

  def index
    render text: 'index'
  end

  def show
    render text: 'show'
  end
end
