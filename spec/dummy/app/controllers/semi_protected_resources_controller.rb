class SemiProtectedResourcesController < ApplicationController
  before_action :doorkeeper_authorize!, only: [:index]

  def index
    render text: 'protected index'
  end

  def show
    render text: 'protected show'
  end
end
