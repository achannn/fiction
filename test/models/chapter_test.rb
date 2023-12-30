require "test_helper"

class ChapterTest < ActiveSupport::TestCase
  test "prev returns the previous chapter" do
    chapter2 = stories(:one).chapters.create(number: 2, title: "2", body: "two")
    assert_equal chapters(:one), chapter2.prev
  end

  test "prev returns nil if it is the first chapter" do
    stories(:one).chapters.create(number: 2, title: "2", body: "two")
    assert_nil chapters(:one).prev
  end

  test "next returns the next chapter" do
    chapter2 = stories(:one).chapters.create(number: 2, title: "2", body: "two")
    assert_equal chapter2, chapters(:one).next
  end

  test "next returns nil if it the last chapter" do
    chapter2 = stories(:one).chapters.create(number: 2, title: "2", body: "two")
    assert_nil chapter2.next
  end
end
