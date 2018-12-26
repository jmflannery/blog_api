class ApplicationController < ActionController::API
  include Toker::TokenAuthentication
  include ActionController::HttpAuthentication::Basic::ControllerMethods
end
