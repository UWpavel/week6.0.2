require "test/unit"
require "rubygems"
require "mocha"

require "uwchat"

class TestAuthServer < Test::Unit::TestCase
 
  DATA = { 'bob' => 'pa$$wd' }
  
  # Testing all the methods except for the authentication sequence
  def setup
    # mocking session, overwriting as needed
    @session = stub( 'session_setup',
      :puts => "send", 
      :gets => "receive")
    
    YAML.expects( :load_file ).returns( DATA )
    
    @aserver = AuthServer.new
    @aserver.user = DATA.keys.first
  end
  
  def test_uwchat_items
    assert_respond_to( @aserver, :logger )
    assert_respond_to( @aserver, :chksum )
    
    assert_not_nil(AuthServer::PORT)
    assert_not_nil(AuthServer::HOST)
    assert_not_nil(AuthServer::MAXCONS)
    
    str = "some_string"
    
    expected  = Digest::MD5.hexdigest( str )
    actual    = @aserver.chksum( str )
    
    assert_equal expected, actual
  end
  
  def test_chksum_handles_multistr
    str1, str2, str3 = "one", "two", "three"
    
    expected  = Digest::MD5.hexdigest( str1 + str2 + str3 )
    actual    = @aserver.chksum( str1, str2, str3 )
    
    assert_equal expected, actual
  end
  
  def test_verify_making_salt  
    salt = @aserver.send_salt( @session )
    
    assert_equal( 32, salt.length )
  end
  
  def test_salt_uniqness
    salt1 = @aserver.send_salt( @session )
    salt2 = @aserver.send_salt( @session )
    
    assert_not_equal( salt1, salt2 )
  end
  
  def test_empty_user_not_authorized
    data = { "realUser" => "passwd" }
    session = mock("session1")
    session.expects( :puts ).once
    
    YAML.expects( :load_file ).returns( data )
    
    aserver = AuthServer.new
    aserver.user = ""
    salt = aserver.chksum( "test_str" )
    passwd_salty = aserver.chksum( salt, data[aserver.user] )
    actual = aserver.authenticate?( session, salt, passwd_salty )
    
    assert_equal false, actual 
  end
  
  def test_authenticate?
    salt = @aserver.chksum( "test_str" )
    passwd_salty = Digest::MD5.hexdigest( salt + DATA[@aserver.user] )
    
    assert @session.expects( :puts ).once
    assert @aserver.authenticate?( @session, salt, passwd_salty )
  end
  
  
  def test_recieved_valid_username
   user = DATA.keys.first
   
   @session.expects( :gets ).returns( user )
   actual = @aserver.get_username( @session )
   
   assert_equal( user, actual )   
  end

  def test_recieving_valid_salty_passwd
    some_md5 = @aserver.chksum( 'dodo' )
    @session.expects( :gets ).returns( some_md5 )
    actual = @aserver.get_salty_passwd( @session )
    
    assert_equal( some_md5, actual )
  end
 
end