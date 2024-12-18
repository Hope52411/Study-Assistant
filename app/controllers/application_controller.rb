class ApplicationController < ActionController::Base
 allow_browser versions: :modern


  def after_sign_in_path_for(resource)
    plans_path  
  end
end
