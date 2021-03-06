class MessagesController < ApplicationController
  before_action :authenticate_user!, :only => [:create]

  def create
    @message = Message.new(message_params)
    conversation = Conversation.find(message_params['conversation_id'])

    if @message.save
      Analytics.track(
        user_id: current_user.id,
        event: 'New Message',
        properties: { action: params['commit'] }
      )

      if params['commit'] == "Send & Archive"
        conversation.archive
        redirect_to conversations_path(current_account)
      else
        redirect_to conversation_path(current_account, @message.conversation)
      end


    else
      Analytics.track(user_id: current_user.id, event: 'Message Save Problem')
      redirect_to conversation_path(current_account, @message.conversation), alert: "Problem"
    end
  end

  def message_params
    params.require(:message).permit(:content, :conversation_id, :internal).merge(person_id: current_user.person.id)
  end
end
