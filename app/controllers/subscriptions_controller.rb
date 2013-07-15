class SubscriptionsController < InheritedResources::Base
  actions :all, except: [ :destroy, :create ]
  load_and_authorize_resource except: [:create]

  def new
    unless params[:event_id] && (event = Event.find(params[:event_id])).ongoing?
      redirect_to root_url
    else
      @application = ApplicationForm.new.load_from params, current_user
      @application.user = current_user
      @application.field_fills = event.field_fills
    end
  end

  def create
    @application = ApplicationForm.new.load_from(params[:subscription])
    @application.user = current_user
    @application.generate_number
    if @application.submit
      sign_in @application.user unless current_user
      flash[:notice] = t 'helpers.messages.subscription.successfully_created'
      redirect_to @application.subscription
    else
      render :new
    end
  end

  def edit
    sub = Subscription.find(params[:id])
    if sub.event.ongoing? && sub.event.allow_edit
      @application = ApplicationForm.new
      @application.subscription = sub
    else
      redirect_to root_url
    end
  end

  def update
    @application = ApplicationForm.new
    sub = Subscription.find(params[:id])
    @application.subscription = sub
    if sub.event.ongoing? && sub.event.allow_edit
      if @application.submit params[:subscription]
        redirect_to sub
      else
        render :edit
      end
    else
      redirect_to root_url
    end
  end

  def index
    @subscriptions = Subscription.accessible_by(current_ability).includes :event
  end

  def show
    @subscription = Subscription.includes(field_fills: :event_field).find(params[:id])
  end
end
