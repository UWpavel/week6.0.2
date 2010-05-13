require 'yaml'

# Authentication server class
class AuthServer
  include Uwchat
  
  # attr_reader :user
  attr_accessor :user
  
  def initialize
    file = File.dirname(__FILE__) + '/passwd'
    @data = YAML.load_file( file )
  end
  
  # Authentication sequence with debug messages, error mesgs will come from corresponding methods
  def auth_sequence( io )
    logger "--- #{io.peeraddr[2]} connected."
    get_username( io )
    logger "--- Received \"#{@user}\" for username."
    salt = send_salt( io )
    logger "--- Sent salt to the client."
    passwd_salty = get_salty_passwd( io )
    logger "--- Received salty password from the client."
    return authenticate?( io, salt, passwd_salty )
  end
  
  # Getting username, and verifying it against our data
  def get_username( io )
    @user = io.gets.chomp
  end
  
  # Generating salt and sending it to the client
  def send_salt( io )
    salt = chksum( @user, Time.now.strftime('%M%S'), rand(300).to_s )
    io.puts salt
    return salt
  end
  
  # Receiving and verifying salt
  def get_salty_passwd( io )
    passwd_salty = io.gets.chomp
    return passwd_salty
  end
  
  # Authentication
  def authenticate?( io, salt, passwd_salty )
    if passwd_salty == chksum( salt, @data[@user] ) and @data[@user]
      result = "AUTHORIZED"
    else
      result = "NOT AUTHORIZED"
    end
    io.puts result
    logger "#{result} \"#{@user}\"."
    return result == "AUTHORIZED"
  end

end