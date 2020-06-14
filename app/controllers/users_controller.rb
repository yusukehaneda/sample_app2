class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  # GET /users
  def index
    @users = User.paginate(page: params[:page])  
  end

  # GET /users/:id  
  def show
    # user = User.first ローカル変数(このアクションでしか使えない。ビューには使えない) 
    #@がつくとインスタンス変数（ビューにも渡せる） @@はglobal変数
    #@user = User.first
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    #debugger
  end

 # GET /users/new
  def new
    @user = User.new
  end


 # POST /users (+ params)

  def create
    #debugger
    #User.create(params[:user])
    @user = User.new(user_params)
    if @user.save
      #UserMailer.account_activation(@user).deliver_now
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
      #log_in @user
      #flash[:success] = "Welcome to the Sample App!"
      # GET "/users/#{@user.id}"
      #redirect_to @user
      # redirect_to user_path(@user) ##user_pathは/users/のこと
      # redirect_to user_path(@user.id)
      # redirect_to user_path(1) => /users/1
      # Success (valid params)
    else
      # Failure (not valid params)
      render 'new'
    end
  end

  # edit_user GET  /users/:id/edit  users#edit
  def edit
    @user = User.find(params[:id])
    # => デフォルトでapp/views/users/edit.html.erbが呼び出される
  end

  # PATCH /users/:id
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user    
    else
       # user.errors <=ここにデータが入っている
      render 'edit'  
    end
  end

  # DELETE /users/:id 
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # beforeアクション


    # 正しいユーザーかどうか確認
    # current_userはログインしていないと呼び出せない
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end

end
