require 'socket'
require 'digest/md5'

module Uwchat
  STUDENT = "Pavel Snagovsky"
  VERSION = '0.0.2'
  
  HOST = 'localhost'
  PORT = 36963
  MAXCONS = 10
  
  def logger( msg )
    puts "[#{Time.now}]: #{msg}"
  end
  
  def chksum( *strs )
    return Digest::MD5.hexdigest( strs.join )
  end
  
end

require 'uwchat/server'
require 'uwchat/client'
require 'uwchat/auth_server'
require 'uwchat/auth_client'