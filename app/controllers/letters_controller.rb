class LettersController < ApplicationController
  before_action :authenticate
  before_action :set_letter, :only => [:show, :edit, :update, :destroy]

  def index
    @letters = Letter.order("date_of_writing DESC").page(params[:page]).per(10)
  end

  def show
  end

  def new
    @letter = Letter.new
  end

  def create
    redirect_to new_letter_path, :notice => t("letters.created")
    return
    
    @letter = Letter.new(letter_params)

    if @letter.save
      redirect_to @letter, :notice => t("letters.created")
    else
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @letter.update(letter_params)
      redirect_to @letter, :notice => t("letters.updated")
    else
      render :action => "edit"
    end
  end

  def destroy
    @letter.destroy

    redirect_to letters_path, :notice => t("letters.deleted")
  end

  def parse_dating
    render :json => Dating.parse(params[:query], :base => params[:base])
  end

  def dating_help
    render :layout => false
  end

  def dating_adjust
    @dating = Dating.parse(params[:query], :base => params[:base]) || Dating::ParseResult.new([], 100, nil)

    render :layout => false
  end

  private
    def set_letter
      @letter = Letter.where(:token => params[:id]).first!
    end

    def letter_params
      params.require(:letter).permit(
        :sender_name, :sender_address,
        :recipient_name, :recipient_address,
        :date_of_writing
      )
    end
end
