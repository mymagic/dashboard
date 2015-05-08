class MessagesController < ApplicationController
  before_action :authenticate_member!
  load_resource :receiver, class: 'Member',
                id_param: :member_id, only: [:create, :index]
  load_and_authorize_resource :message, through: :current_member, except: :index

  after_action :mark_messages_as_read, only: :index

  def index
    if @receiver.present?
      @messages = current_member.messages_with(@receiver)
      @participants = current_member.chat_participants
      @unread_messages = current_member.unread_messages_with(@participants)
    end
  end

  def create
    if @message.update(sender: current_member, receiver: @receiver)
      flash[:notice] = 'Message has already send.'
    else
      flash[:alert] = 'Error sending message.'
    end

    redirect_to community_member_messages_path(current_community, @receiver)
  end

  def search
    @messages = current_member.messages.search(params['term'])
  end

  protected

  def message_params
    params.require(:message).permit(:body)
  end

  def mark_messages_as_read
    @messages.update_all(unread: false)
  end
end
