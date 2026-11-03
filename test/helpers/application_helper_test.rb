require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "naira formats with symbol, thousands and kobo" do
    assert_equal "₦12,500.00", naira(12_500)
    assert_equal "₦4,500,000.50", naira(BigDecimal("4500000.5"))
    assert_equal "₦0.00", naira(nil)
  end
end
