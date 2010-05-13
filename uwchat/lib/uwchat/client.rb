require 'timeout'

class ChatClient
  include Uwchat

  def initialize( host = HOST, port = PORT )  
    begin
      @session = TCPSocket.new( host, port )
    rescue
      puts "Failed to connect to #{host}:#{port}"
      exit 1
    end
    puts "Connected to ChatServer on #{host}. To exit the client: \'exit\'"
  end
  
  def authenticate(user, passwd)
    begin
      Timeout::timeout(2) do
        @result = AuthClient.new( @session ).authenticate?(user, passwd)
      end
    rescue Timeout::Error
      puts "\nAuthentication timed out."
      exit 1
    end
    
    chat if @result
  end
  
  private
  
  def chat
    incoming = Thread.new do
      while msg = @session.gets
        puts msg
      end
    end
     
    outgoing = Thread.new do
      while msg = STDIN.gets.chomp
        exit 0 if msg =~ /disconnect|exit|^quit/
        begin
          @session.puts( msg )
        rescue
          puts "Failed to communicate to the Chat server. Exiting."
          exit 1
        end
      end
    end
    
    incoming.join
    outgoing.join
  end

end