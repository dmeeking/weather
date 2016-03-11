class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
	
  helper_method :current_conditions

  before_filter :ensure_domain
  APP_DOMAIN = 'www.yowx.ca'
  def ensure_domain
	if Rails.env.production?
	    if request.env['HTTP_HOST'] != APP_DOMAIN
	      # HTTP 301 is a "permanent" redirect
	      redirect_to "http://#{APP_DOMAIN}", :status => 301
	    end
	end
  end


  def current_conditions
  	WeatherReading.order(reading_at: :desc).pluck(:temperature, :wind_speed, :wind_direction).first
  	
  end


end
