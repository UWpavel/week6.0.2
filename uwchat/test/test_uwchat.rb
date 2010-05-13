require "test/unit"
require "uwchat"

class TestUwchat < Test::Unit::TestCase
  
  def test_me
    assert_equal "Pavel Snagovsky", Uwchat::STUDENT
  end
  
end
