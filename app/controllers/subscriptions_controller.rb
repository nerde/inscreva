class SubscriptionsController < InheritedResources::Base
  actions :all, except: [ :destroy, :create ]
  load_and_authorize_resource except: [:create]
  respond_to :html
  include SubscriptionsHelper

  def new
    @event = Event.find(params[:event_id])
    unless @event.ongoing?
      redirect_to root_url
    else
      @application = ApplicationForm.new.load_from params, current_user
      @application.user = current_user
      @application.field_fills = @event.field_fills
    end
  end

  def create
    @event = Event.find(params[:event_id])
    @application = ApplicationForm.new.load_from(params[:subscription])
    @application.user = current_user
    @application.generate_number
    @application.event = @event
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

  def mine
    @subscriptions = current_user.subscriptions.includes(:event).page(params[:page])
  end

  def show
    @subscription = Subscription.find(params[:id])
  end

  def receipt
    @subscription = Subscription.find(params[:id])
    render layout: 'printing_page'
  end

  protected

  def collection
    @event = Event.find(params[:event_id])
    @subscriptions = @event.subscriptions.accessible_by(current_ability).page(params[:page])
    @subscriptions = @subscriptions.search(params[:term]) unless params[:term].blank?
    params[:fields].each do |k,v|
      if v.key?(:value) and filter_valid?(k, v[:value], v[:type])
        clause, query_params = filter_clause(k, v[:value], v[:type])
        @subscriptions = @subscriptions.where('subscriptions.id in (select ' +
            "subscription_id from field_fills where #{clause})", *query_params)
      end
    end if params[:fields]
  end
end
