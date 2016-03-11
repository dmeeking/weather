class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception


  before_filter :ensure_domain
  
  def ensure_domain
	if Rails.env.production?
	    if request.env['HTTP_HOST'] != config.production_url
	      # HTTP 301 is a "permanent" redirect
	      redirect_to "http://#{config.production_url}", :status => 301
	    end
	end
  end
end
