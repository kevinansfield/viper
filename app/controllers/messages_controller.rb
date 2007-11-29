class MessagesController < ApplicationController
  before_filter :login_required, :find_user_and_message
  before_filter :protect_message, :except => [:new, :create]
  
  tab :hub
  tab :community, :only => :new
  
  def index
    @messages = @user.received_messages.paginate :page => params[:page]
  end
  
  def sent
    @messages = @user.sent_messages.paginate :page => params[:page]
  end
  
  def show
    if current_user == @message.receiver
      @message.read_at = Time.now
      @message.save
    end
  end
  
  def new
    @message = Message.new
  end
  
  def reply
    @old_message = @message
    @message = Message.new
    @message.receiver_id = @old_message.sender_id
    @message.subject = "RE: #{@old_message.subject}"
    @message.body = ""
    @message.body += "\r\n\r\n\r\n--------------------"
    @message.body += "\r\nReceived from #{@old_message.sender.full_name} at #{@old_message.created_at}"
    @message.body += "\r\n\r\n#{@old_message.body}"
    render :action => 'new'
  end
  
  def create
    message = Message.new(params[:message])
    recipient = message.receiver || @user
    current_user.send_message(recipient, message)
    respond_to do |format|
      format.html do
        flash[:notice] = 'Message Sent'
        redirect_to messages_path(current_user)
        false;
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :action => 'new'
  end
  
  def destroy
    
  end
  
  private
  
  def find_user_and_message
    @user = User.find_by_permalink(params[:user_id])
    @message = params[:id].nil? ? nil : @message = Message.find(params[:id])
  end
  
  def protect_message
    unless @user == current_user || @message && @user == @message.sender || @message && @user == @message.receiver
      flash[:error] = "You don't have permission to see that page!"
      redirect_to hub_url
      return false
    end
  end
  
end
