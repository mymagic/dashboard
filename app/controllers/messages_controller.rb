class MessagesController < ApplicationController
  before_action :authenticate_member!
  load_resource :receiver, class: 'Member',
                id_param: :member_id, only: [:create, :index]
  load_resource :message, through: :current_member, except: :index

  def index
    @messages = current_member.messages_with(@receiver)
    @members = current_community.members.active.where.not(id: current_member.id)
  end

  def create
    if @message.update(sender: current_member, receiver: @receiver)
      flash[:notice] = 'Message has already send.'
    else
      flash[:alert] = 'Error sending message.'
    end

    redirect_to community_member_messages_path(current_community, @receiver)
  end

  protected

  def message_params
    params.require(:message).permit(:body)
  end
end
