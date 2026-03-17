require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  test "default inactive" do
    u = users(:one) rescue User.new(email: 't@example.com', password: 'password')
    s = Subscription.new(user: u, status: 'pending')
    assert_not s.active?
  end
end
