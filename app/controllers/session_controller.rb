class SessionController < ApplicationController
  before_filter :ensure_logged_out, :only => [:new, :create]
  before_filter :ensure_logged_in, :only => :destroy

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(session_params)

    if @session.valid?
      session[:user_id] = @session.user.id
      I18n.locale = @session.user.locale
      redirect_to return_path, :notice => t("session.logged_in", :name => @session.user.first_name)
    else
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, :notice => t("session.logged_out")
  end

  private
    def session_params
      params.require(:session).permit :login, :password
    end

    def return_path
      if (return_url = params[:return_to].presence) && return_url.is_a?(String) && return_url =~ /\Ahttps?:\/\//
        return_url =~ /\Ahttps?:\/\/[^\/]+(.*)/ && $1
      else
        root_path
      end
    end
end
