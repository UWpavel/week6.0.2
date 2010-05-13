require "test/unit"
require "rubygems"
require "mocha"

require "uwchat"

class TestChatServer < Test::Unit::TestCase
  
  def setup
    port = 12345
    @users = %w( user100 user101 user102 )
    clients = {} 
    @test_msg = "test message"
    
    # mocking io  
    @io = stub( 'io_simulation',
      :gets     => "send",
      :puts     => "receive",
      :close    => "closed",
      :closed?  => false,
      :peeraddr => [1, 2, 'localhost'] )
    
    @users.each { |u| clients[u] = @io }
    
    @server = ChatServer.new( port )
    # giving our server few clients
    @server.instance_variable_set( :@clients, clients )
  end
  
  def test_uwchat_items
    assert_respond_to( @server, :logger )
    assert_respond_to( @server, :chksum )
    
    assert_not_nil(ChatServer::PORT)
    assert_not_nil(ChatServer::HOST)
    assert_not_nil(ChatServer::MAXCONS)
    
    str = "some_string"
    
    expected  = Digest::MD5.hexdigest( str )
    actual    = @server.chksum( str )
    
    assert_equal expected, actual
  end
  
  def test_chksum_handles_multistr
    str1, str2, str3 = "one", "two", "three"
    
    expected  = Digest::MD5.hexdigest( str1 + str2 + str3 )
    actual    = @server.chksum( str1, str2, str3 )
    
    assert_equal expected, actual
  end
   
  def test_new_user
    user = "user0"
    
    aserver = mock('auth-server')
    aserver.expects( :user ).returns( user )
    aserver.expects( :auth_sequence ).with( @io ).returns( true )
    AuthServer.expects( :new ).returns( aserver )
    # create 'user0'
    @server.new_client( @io )
    
    expected = false
    actual = @server.instance_variable_get( :@clients )[user].closed?
    
    assert_equal expected, actual
  end
  
  def test_client_removal
    user = @users.first
    
    before = @server.instance_variable_get( :@clients ).size
    @server.client_left( user )
    after = @server.instance_variable_get( :@clients ).size
    
    assert before > after
  end
  
  def test_process_msg
    users = @server.instance_variable_get( :@clients ).size
    @io.expects( :puts ).times( users - 1 )    
    
    assert @server.process_msg( @users.last, @test_msg )
  end
  
  def test_process_msg_removes_client_with_closed_con
    before = @server.instance_variable_get( :@clients ).size
    @io.expects( :closed? ).returns( true )
    @server.process_msg( @users.last, @test_msg )
    after = @server.instance_variable_get( :@clients ).size
    
    assert_not_equal before, after
  end
  
  def test_client_quit_command
    user = @users.last
    # insure we have the user
    assert  @server.instance_variable_get( :@clients )[user]
    
    before = @server.instance_variable_get( :@clients ).size
    @server.process_command( user, "/quit" )
    after = @server.instance_variable_get( :@clients ).size
    
    assert_not_equal before, after
    assert_nil @server.instance_variable_get( :@clients )[user]
  end
  
  def test_testing_user
    user = @users.last
    assert  @server.instance_variable_get( :@clients )[user]
    
    actual = @server.test_user?( user, @io )
    assert_equal false, actual
  end
  
  def test_testing_user_allow
    user = "not_conected"    
    assert_nil  @server.instance_variable_get( :@clients )[user]
    
    assert @server.test_user?( user, @io ) 
  end    
  
  def test_testing_user_closes_connection
    user = @users.last
    
    assert @io.expects( :close ).once    
    @server.test_user?( user, @io )
  end
  
  def test_user_welcome_adds_user
    user = "user00"
    assert_nil  @server.instance_variable_get( :@clients )[user]
    
    before = @server.instance_variable_get( :@clients ).size
    @server.user_welcome( user, @io )
    after = @server.instance_variable_get( :@clients ).size
    
    assert before < after
  end
  
end