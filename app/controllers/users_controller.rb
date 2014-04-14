class UsersController < ApplicationController
  before_action :authenticate
  before_action :authorize_admin
  before_action :set_user, :only => [:show, :edit, :update, :destroy]

  def index
    @users = User.order(:login)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to @user, :notice => t("users.created")
    else
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @user.update(user_params.except(:login))
      redirect_to @user, :notice => t("users.updated")
    else
      render :action => "edit"
    end
  end

  def destroy
    @user.trash

    redirect_to users_path, :notice => t("users.deleted")
  end

  private
    def set_user
      @user = User.where(:login => params[:id]).first!
    end

    def user_params
      params.require(:user).permit :login, :first_name, :last_name, :password, :password_confirmation, :locale
    end
end
