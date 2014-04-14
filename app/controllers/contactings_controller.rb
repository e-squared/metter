class ContactingsController < ApplicationController
  def new
    @contacting = Contacting.new
  end

  def create
    @contacting = Contacting.new(contacting_params)

    @contacting.user_agent = request.user_agent
    @contacting.ip_address = request.remote_ip

    if @contacting.save
      @contacting.deliver_mail

      redirect_to contact_path, :notice => t("contactings.created")
    else
      render :action => "new"
    end
  end

  private
    def contacting_params
      params.require(:contacting).permit(:name, :email, :subject, :message)
    end
end
