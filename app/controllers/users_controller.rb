class UsersController < ApplicationController

  # GET /users/:id  
  def show
    # user = User.first ローカル変数(このアクションでしか使えない。ビューには使えない) 
    #@がつくとインスタンス変数（ビューにも渡せる） @@はglobal変数
    #@user = User.first
    @user = User.find(params[:id])
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
      # GET "/users/#{@user.id}"
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
      # redirect_to user_path(@user) ##user_pathは/users/のこと
      # redirect_to user_path(@user.id)
      # redirect_to user_path(1) => /users/1
      # Success (valid params)
    else
      # Failure (not valid params)
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

end
