require "application_responder"

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html
  protect_from_forgery
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) { |u| u.slice(:email,
        :password, :password_confirmation, :current_password, :name) }
  end
end
