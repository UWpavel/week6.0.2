require "test/unit"
require "rubygems"
require "mocha"

require "uwchat"

class TestAuthClient < Test::Unit::TestCase
  
  def setup
    @session = stubs( :puts )   

    @client = AuthClient.new( @session )
  end
  
  def test_uwchat_items
    assert_respond_to( @client, :logger )
    assert_respond_to( @client, :chksum )
    
    assert_not_nil(AuthClient::PORT)
    assert_not_nil(AuthClient::HOST)
    assert_not_nil(AuthClient::MAXCONS)
    
    str = "some_string"
    
    expected  = Digest::MD5.hexdigest( str )
    actual    = @client.chksum( str )
    
    assert_equal expected, actual
  end
  
end