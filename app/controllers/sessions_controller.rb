class SessionsController < ApplicationController
  # GET /login
  def new
   #scope: :session + login_path
  end

  # POST /login
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or user
      else
        #message  = "Account not activated. "
        #message += "Check your email for the activation link."
        message  = t('.not activated')
        message += t('.check email')
        flash[:warning] = message
        redirect_to root_url
      end
       #ここの@userは !@user.nil?（nilじゃなければ）と同じ
       #nilとかfalse以外はtrueになる
       # Success #log_in(@user)
      #log_in user #session[:user_id] = user.id

      #ここのrememberはsessions_helperで定義したもの（app/models/user.rbで定義したものではない）
      #params[:session][:remember_me] == '1' ? remember(user) : forget(user)

     #redirect_to user #ここのuserはuser_path(user.id)と同じ
      #redirect_back_or user # foearding urlがあればそちらに飛ばす(sessions_helperで定義)
    else
       # Failure
       # alert-danger => 赤色のフラッシュ
       #flash.now[:danger] = 'Invalid email/password combination'
       flash.now[:danger] = t('.invalid combination')
       render 'new'
    end
  end

  #DELETE /logout
  def destroy
    log_out if logged_in?
    redirect_to root_url #root_pathでもいい
  end

end
