class EventsController < ApplicationController
  before_action :set_project_or_redirect
  before_action :set_event_or_redirect, except: [:create]

  def show
  end

  def edit
  end

  def create
    @event = Event.new(event_params.merge({project_id: @project.id, user_id: current_user.id}))

    respond_to do |format|
      if @event.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @event.update(event_params)
    redirect_to project_event_path(@project, @event)
  end

  def destroy
    respond_to do |format|
      if @event.destroy
        format.js
      else
        format.js
      end
    end
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :status, :start_at, :end_at)
  end

  def set_event_or_redirect
    @event = Event.find(params[:id])
    redirect_to project_path(@project), alert: "You cannot modify that event." unless current_user.can_manage_resource?(@event)
  end
end
