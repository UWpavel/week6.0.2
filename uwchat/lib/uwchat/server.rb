require 'gserver'

class ChatServer < GServer
  include Uwchat
  
  def initialize( port = PORT, host = HOST, *args )
    super( port, host, *args )
    @clients = {}
  end
  
  def serve( io )
    nick = new_client( io )     
    while msg = io.gets
      logger "Msg from #{nick} >> #{msg.chomp}"
      begin
        if msg =~ /^\//
          process_command( nick, msg )
        else
          process_msg( nick, msg )
        end
      rescue Exception => e
        puts e.message
        raise
      end
    end
  end 
  
  # Broadcasting message to all clients
  def process_msg( sender, msg )
    @clients.each do |user, io|
      if io.closed?
        client_left( user )
        next
      end
      next if sender == user
      io.puts( "#{sender} >> #{msg}")
    end
  end
  
  # Handle incomming commands
  def process_command( sender, msg )
    case msg
    when /quit$/
      @clients[ sender ].close
      @clients.delete( sender )    
      server_msg = "User #{sender} has quit the chat."
    when /help$/
      help_msg = "Supported commands: /help; /quit."
      @clients[ sender ].puts( help_msg )
      server_msg = "Help requested."
      for_server = "By #{sender}"
    else
      server_msg = "Unsupported command called."
      for_server = "#{sender} called #{msg}"
    end
    process_msg( "ChatServer", server_msg)
    logger( "#{server_msg} #{for_server}" )
  end
  
  # Take care of incoming clients
  def new_client( io )
    auth = AuthServer.new
    if auth.auth_sequence( io )
      new_user = auth.user
      user_welcome( new_user, io ) if test_user?(new_user, io)
      return new_user
    else
      io.close
    end
  end
  
  # Testing if incoming user already connected
  # Closed connections will be cleared and user would be allowed to login
  def test_user?( user, io )
    if @clients.has_key?( user )
      if @clients[user].closed?
        client_left( user )
        return true
      end
      io.puts "Connection denied: #{user} is in use, connected from: #{@clients[user].peeraddr[2]}."
      logger "Denied login for #{user} from #{io.peeraddr[2]}, username is in use."
      io.close
      return false
    end
    return true
  end
  
  # User welcome or not
  def user_welcome( user, io )
    @clients[ user ] = io
    io.puts "Welcome #{user}. For help enter: /help."
    process_msg "ChatServer", "#{user} joined the chat."
    logger "#{user} joined the chat."
  end
  
  # Remove a client (at this point connection is closed)
  def client_left( user )
    @clients.delete( user )
    msg = "#{user} left the Server."
    logger( msg )
    process_msg( "ChatServer", msg )
  end
  
end