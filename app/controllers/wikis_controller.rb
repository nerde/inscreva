class WikisController < InheritedResources::Base
  load_and_authorize_resource except: :present
  belongs_to :event, shallow: true
  actions :all
  respond_to :html

  def present
    @event = Event.find_by_identifier params[:event]
    not_found unless @event
    if params[:wiki]
      @wiki = @event.wikis.find_by_name(params[:wiki])
    else
      if @wiki = @event.main_wiki
        redirect_to present_event_wiki_path(params[:event], @wiki.name)
        return
      end
    end
    not_found unless @wiki
  end
end
