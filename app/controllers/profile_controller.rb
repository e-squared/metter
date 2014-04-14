class ProfileController < ApplicationController
  before_filter :authenticate

  def index
  end

  def edit
  end

  def update
    if current_user.update(user_params)
      I18n.locale = current_user.locale
      redirect_to root_path, :notice => t("profile.updated")
    else
      render :edit
    end
  end

  private
    def user_params
      params.require(:user).permit :first_name, :last_name, :password, :password_confirmation, :locale
    end
end
