class MessagesController < ApplicationController
  before_action :authenticate_member!
  load_resource :receiver,
                class: 'Member',
                id_param: :member_id,
                only: [:create, :index]
  before_action :redirect_if_invalid_receiver, only: :index
  load_and_authorize_resource :message, through: :current_member, except: :index

  after_action :mark_messages_as_read, only: :index

  def index
    return unless @receiver.present?
    @messages = current_member.messages_with(@receiver).ordered
    @participants = current_member.chat_participants
    @unread_messages = current_member.unread_messages_with(@participants)
  end

  def create
    authorize! :send_message_to, @receiver
    if @message.update(sender: current_member, receiver: @receiver)
      flash[:notice] = 'Message has been sent.'
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
    return if @messages.blank?

    @messages.
      where.not(sender: current_member).
      update_all(unread: false)
  end

  def redirect_if_invalid_receiver
    authorize! :read_messages_with, @receiver if @receiver.present?
  end
end
