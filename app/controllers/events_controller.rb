class EventsController < ApplicationController
  before_action :authenticate
  before_action :set_event, :only => [:show, :edit, :update, :destroy]

  def index
    @events =
      if query_param
        if params[:mode] == "picker"
          result = Dating.parse(params[:query], :base => params[:base])

          if result
            dates = result.dates

            if dates.size == 1 && dates.first.is_a?(Date)
              dates = (dates.first - 3)..(dates.first + 3)
            end

            Event.where(:date => dates).order(:date)
          else
            []
          end
        else
          Event.search(query_param,
            #:order  => 'date DESC',
            :page => params[:page], :per_page => 10,
            :populate => true, :star => true
          )
        end
      else
        Event.order("date DESC").page(params[:page]).per(10)
      end
  end

  def show
  end

  def new
    @event = event_class.new
  end

  def create
    @event = event_class.new(event_params)

    if @event.save
      redirect_to @event, :notice => t("events.created")
    else
      render :action => "new"
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to @event, :notice => t("events.updated")
    else
      render :action => "edit"
    end
  end

  def destroy
    @event.destroy

    redirect_to events_path, :notice => t("events.deleted")
  end

  private
    def set_event
      @event = Event.where(:token => params[:id]).first!
    end

    def event_params
      params.require(:event).permit :date, :description
    end

    def query_param
      @query_param ||= params[:query].presence && Riddle::Query.escape(params[:query])
    end

    def event_class
      type = params[:type]

      if type.present? && type =~ /\A\S+Event\z/
        type.constantize
      else
        Event
      end
    end
end
