class PeopleController < ApplicationController
  before_action :authenticate
  before_action :set_person, :only => [:show, :edit, :update, :destroy]

  def index
    @people =
      if query_param
        result = Person.search(query_param,
          :select => '*, @weight, @weight + person_rank as custom_weight',
          :order  => 'person_rank DESC',
          :page => params[:page], :per_page => 10,
          :populate => true#, :star => true
        )

        result.context[:panes] << ThinkingSphinx::Panes::WeightPane
        result
      else
        Person.order(:id).page(params[:page]).per(10)
      end
  end

  def images
    @people = Person.where("wikipedia_image_url IS NOT NULL").order(:id).page(params[:page]).per(5000)
  end

  def remove_image
    Person.where(:id => params[:id]).first.update_column :wikipedia_image_url, nil

    render :nothing => true
  end

  def show
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.json do
          @person.destroy # prototype
        end

        format.html do
          redirect_to @person, :notice => t("people.created")
        end
      else
        format.json do
          render :json => @person.errors.full_messages, :status => :unprocessable_entity
        end

        format.html do
          render :action => "new"
        end
      end
    end
  end

  def edit
  end

  def update
    if @person.update(person_params)
      redirect_to @person, :notice => t("people.updated")
    else
      render :action => "edit"
    end
  end

  def destroy
    @person.destroy

    redirect_to people_path, :notice => t("people.deleted")
  end

  private
    def set_person
      @person = Person.where(:token => params[:id]).first!
    end

    def person_params
      params.require(:person).permit(
        :name, :description, :rank, { :alternative_names => [] },
        :date_of_birth, :unformatted_date_of_birth,
        :date_of_death, :unformatted_date_of_death,
        :place_of_birth, :place_of_death,
        :wikipedia_identifier, :viaf_identifier,
        :gnd_identifier, :lccn_identifier,
        :wikipedia_image_url, :wikipedia_about_html
      )
    end

    def query_param
      @query_param ||= params[:query].presence && Riddle::Query.escape(params[:query])
    end
end
