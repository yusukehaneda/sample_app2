class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      #user.update_attribute(:activated,    true)
      #user.update_attribute(:activated_at, Time.zone.now)
      log_in user
      message = t('.activated')
      flash[:success] = message
      redirect_to user
    else
      message = t('.invalid activation link')
      flash[:danger] = message
      redirect_to root_url
    end
  end
end
