# Authentication client class
class AuthClient
  
  include Uwchat
  
  def initialize( session )
    @session = session
  end
  
  def get_salt( user )
    @session.puts user
    return @session.gets.chomp
  end
  
  def send_salty_passwd( passwd, salt )
    @session.puts chksum( salt, passwd )
    return @session.gets.chomp
  end
  
  def authenticate?(user, passwd)
    logger "--- Sending username \"#{user}\""
    salt = get_salt( user )
    logger "--- Recieved \"salt\" from the server. Cooking..."
    logger "--- Sending encrypted passwd"
    result = send_salty_passwd( passwd, salt )
    logger result
    return result == "AUTHORIZED"
  end
  
end