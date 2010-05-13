require "test/unit"
require "rubygems"
require "mocha"

require "uwchat"

class TestChatClient < Test::Unit::TestCase

  HOST, PORT = 'localhost', 12345
  
  def setup
    @session = stubs( :puts )
    @session = stubs( :gets )
    TCPSocket.stubs( :new ).with( HOST, PORT).returns( @session )

    @chat_client = ChatClient.new( HOST, PORT )
  end
  
  def test_no_exception_connecting
    assert_nothing_raised( Exception ) { ChatClient.new( HOST, PORT) }
  end

end