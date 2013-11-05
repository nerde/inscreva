class NotificationsController < InheritedResources::Base
  actions :new, :create
  belongs_to :event, shallow: true
  load_and_authorize_resource

  def new
    @notification.respond = current_user.email
    @notification.filters = params[:filters]
    @notification.load_recipients
    new!
  end

  def create
    @notification.user = current_user
    create! do |suc,fail|
      suc.html {
        NotificationMailer.notify(@notification).deliver
        redirect_to event_subscriptions_path(@event, fields: @notification.filters)
      }
    end
  end

  private

  def resource_params
    return [] if request.get?
    [params.require(:notification).permit(:subject, :respond, :message, :recipients_text).tap do |white|
      white[:filters] = params[:notification][:filters].to_hash if params[:notification][:filters]
    end]
  end
end
